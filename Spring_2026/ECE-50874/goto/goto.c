#include <stdio.h>

int main(){
    int n = 10;
    main:
    n--;
    printf("%d\n", n);
    if (n > 0) {
        goto main;
    }
    printf("Done %d\n", n);
}