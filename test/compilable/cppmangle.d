
// Test C++ name mangling.
// See Bugs 4059, 5148, 7024, 10058

version(linux):

import std.c.stdio;

extern (C++)
        int foob(int i, int j, int k);

class C
{
    extern (C++) int bar(int i, int j, int k)
    {
        printf("this = %p\n", this);
        printf("i = %d\n", i);
        printf("j = %d\n", j);
        printf("k = %d\n", k);
        return 1;
    }
}


extern (C++)
        int foo(int i, int j, int k)
{
    printf("i = %d\n", i);
    printf("j = %d\n", j);
    printf("k = %d\n", k);
    assert(i == 1);
    assert(j == 2);
    assert(k == 3);
    return 1;
}

void test1()
{
    foo(1, 2, 3);

    auto i = foob(1, 2, 3);
    assert(i == 7);

    C c = new C();
    c.bar(4, 5, 6);
}

static assert(foo.mangleof == "_Z3fooiii");
static assert(foob.mangleof == "_Z4foobiii");
static assert(C.bar.mangleof == "_ZN1C3barEiii");

/****************************************/

extern (C++) interface D
{
    int bar(int i, int j, int k);
}

extern (C++) D getD();

void test2()
{
    D d = getD();
    int i = d.bar(9,10,11);
    assert(i == 8);
}

static assert (getD.mangleof == "_Z4getDv");
static assert (D.bar.mangleof == "_ZN1D3barEiii");

/****************************************/

extern (C++) int callE(E);

extern (C++) interface E
{
    int bar(int i, int j, int k);
}

class F : E
{
    extern (C++) int bar(int i, int j, int k)
    {
        printf("F.bar: i = %d\n", i);
        printf("F.bar: j = %d\n", j);
        printf("F.bar: k = %d\n", k);
        assert(i == 11);
        assert(j == 12);
        assert(k == 13);
        return 8;
    }
}

void test3()
{
    F f = new F();
    int i = callE(f);
    assert(i == 8);
}

static assert (callE.mangleof == "_Z5callEP1E");
static assert (E.bar.mangleof == "_ZN1E3barEiii");
static assert (F.bar.mangleof == "_ZN1F3barEiii");

/****************************************/

extern (C++) void foo4(char* p);

void test4()
{
    foo4(null);
}

static assert(foo4.mangleof == "_Z4foo4Pc");

/****************************************/

extern(C++)
{
  struct foo5 { int i; int j; void* p; }

  interface bar5{
    foo5 getFoo(int i);
  }

  bar5 newBar();
}

void test5()
{
  bar5 b = newBar();
  foo5 f = b.getFoo(4);
  printf("f.p = %p, b = %p\n", f.p, cast(void*)b);
  assert(f.p == cast(void*)b);
}

static assert(bar5.getFoo.mangleof == "_ZN4bar56getFooEi");
static assert (newBar.mangleof == "_Z6newBarv");

/****************************************/

extern(C++)
{
    struct S6
    {
        int i;
        double d;
    }
    S6 foo6();
}

extern (C) int foosize6();

void test6()
{
    S6 f = foo6();
    printf("%d %d\n", foosize6(), S6.sizeof);
    assert(foosize6() == S6.sizeof);
    assert(f.i == 42);
    printf("f.d = %g\n", f.d);
    assert(f.d == 2.5);
}

static assert (foo6.mangleof == "_Z4foo6v");

/****************************************/

extern (C) int foo7();

struct S
{
    int i;
    long l;
}

void test7()
{
    printf("%d %d\n", foo7(), S.sizeof);
    assert(foo7() == S.sizeof);
}

/****************************************/

extern (C++) void foo8(const char *);

void test8()
{
    char c;
    foo8(&c);
}

static assert(foo8.mangleof == "_Z4foo8PKc");

/****************************************/
// 4059

struct elem9 { }

extern(C++) void foobar9(elem9*, elem9*);

void test9()
{
    elem9 *a;
    foobar9(a, a);
}

static assert(foobar9.mangleof == "_Z7foobar9P5elem9S0_");

/****************************************/
// 5148

extern (C++)
{
    void foo10(const char*, const char*);
    void foo10(const int, const int);
    void foo10(const char, const char);

    struct MyStructType { }
    void foo10(const MyStructType s, const MyStructType t);

    enum MyEnumType { onemember }
    void foo10(const MyEnumType s, const MyEnumType t);
}

void test10()
{
    char* p;
    foo10(p, p);
    foo10(1,2);
    foo10('c','d');
    MyStructType s;
    foo10(s,s);
    MyEnumType e;
    foo10(e,e);
}

/**************************************/
// 10058

extern (C++)
{
    void test10058a(void*) { }
    void test10058b(void function(void*)) { }
    void test10058c(void* function(void*)) { }
    void test10058d(void function(void*), void*) { }
    void test10058e(void* function(void*), void*) { }
    void test10058f(void* function(void*), void* function(void*)) { }
    void test10058g(void function(void*), void*, void*) { }
    void test10058h(void* function(void*), void*, void*) { }
    void test10058i(void* function(void*), void* function(void*), void*) { }
    void test10058j(void* function(void*), void* function(void*), void* function(void*)) { }
    void test10058k(void* function(void*), void* function(const (void)*)) { }
    void test10058l(void* function(void*), void* function(const (void)*), const(void)* function(void*)) { }
}

static assert(test10058a.mangleof == "_Z10test10058aPv");
static assert(test10058b.mangleof == "_Z10test10058bPFvPvE");
static assert(test10058c.mangleof == "_Z10test10058cPFPvS_E");
static assert(test10058d.mangleof == "_Z10test10058dPFvPvES_");
static assert(test10058e.mangleof == "_Z10test10058ePFPvS_ES_");
static assert(test10058f.mangleof == "_Z10test10058fPFPvS_ES1_");
static assert(test10058g.mangleof == "_Z10test10058gPFvPvES_S_");
static assert(test10058h.mangleof == "_Z10test10058hPFPvS_ES_S_");
static assert(test10058i.mangleof == "_Z10test10058iPFPvS_ES1_S_");
static assert(test10058j.mangleof == "_Z10test10058jPFPvS_ES1_S1_");
static assert(test10058k.mangleof == "_Z10test10058kPFPvS_EPFS_PKvE");
static assert(test10058l.mangleof == "_Z10test10058lPFPvS_EPFS_PKvEPFS3_S_E");

