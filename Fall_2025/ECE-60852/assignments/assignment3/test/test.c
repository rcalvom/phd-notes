#include <malloc.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct SampleStruct {
    void *fieldA;
    void *fieldB;
};

void part1() {
    char *buffer;
    int n;
    n = snprintf(buffer, 1, "%i", 1); // Part1
    buffer += n;
    buffer += snprintf(buffer, 1, "%i", 1); // Part1
    snprintf(buffer, 1, "%i", 1);           // Not detected
}

void part2() {
    char *buffer;
    char *fmt1 = "%s%i";
    char *fmt2 = "%i";

    sprintf(buffer, "%s%i", "", 1); // Part2
    sprintf(buffer, "%i", "", 1);   // Not detected

    sscanf(buffer, "%s%i", "", 1); // Part2
    sscanf(buffer, "%i", "", 1);   // Not detected

    fscanf((FILE *)buffer, "%s%i", "", 1); // Part2
    fscanf((FILE *)buffer, "%i", "", 1);   // Not detected

    sprintf(buffer, fmt1, "", 1); // Part2
    sprintf(buffer, fmt2, "", 1); // Not detected
}

void part3() {
    struct SampleStruct structA;
    struct SampleStruct *structB;
    structA.fieldA = realloc(structA.fieldA, sizeof(struct SampleStruct));   // Part3
    structA.fieldB = realloc(structA.fieldA, sizeof(struct SampleStruct));   // Not detected
    structB->fieldA = realloc(structB->fieldA, sizeof(struct SampleStruct)); // Part3
    structB->fieldB = realloc(structB->fieldA, sizeof(struct SampleStruct)); // Not detected
}

void part4() {
    void *a1 = malloc(100 * 100);            // part4
    void *b1 = calloc(10, sizeof(int) * 10); // part4
    void *c1 = realloc(a1, 200 * 56);        // part4

    void *a2 = malloc(100);             // Not detected
    void *b2 = calloc(10, sizeof(int)); // Not detected
    void *c2 = realloc(a2, 200);        // Not detected

    char *s1 = strdup("hello");     // Not detected
    char *s2 = strndup("world", 3); // Not detected
}

void part5() {
    int *ptr1;
    int *ptr2;
    int *ptr3;
    int *ptr4;
    int *ptr5;

    if (ptr1) {
        free(ptr1); 
    } else {
        free(ptr1); // Not detected
    }

    free(ptr2);
    free(ptr2); // part5

    free(ptr3);
    ptr3 = ptr4;
    free(ptr3); // Not detected

    free(ptr4); // part5

    for(int i = 0; i<2; i++){
        free(ptr5); // part5
    }
}

int main() {
    part1();
    part2();
    part3();
    part4();
    part5();

    return 0;
}