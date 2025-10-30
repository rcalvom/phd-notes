#include <stdio.h>
#include <stdlib.h>

struct test {
    int* a;
};

int main() {
    char *buf;

    sprintf(buf, "%i%s%i", 1, "test", 1);
    
    struct test t1;
    struct test* t2;
    struct test* t3;
    t1.a = realloc(t1.a, 5);
    t3->a = realloc(t2->a, 5); // Not target
    t2->a = realloc(t2->a, 5);

    return 0;
}