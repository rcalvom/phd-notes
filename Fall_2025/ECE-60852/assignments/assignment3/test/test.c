#include <stdio.h>
#include <stdlib.h>

void part1() {
    char *buffer;
    int n;
    n = snprintf(buffer, 1, "%i", 1); // Part1
    buffer += n;
    buffer += snprintf(buffer, 1, "%i", 1); // Part1
    snprintf(buffer, 1, "%i", 1); // Not detected
}

void part2() {
    char *buffer;
    sprintf(buffer, "%s%i", "", 1); // Part2
    sprintf(buffer, "%i", "", 1); // Not detected

    sscanf(buffer, "%s%i", "", 1); // Part2
    sscanf(buffer, "%i", "", 1); // Not detected

    fscanf((FILE*)buffer, "%s%i", "", 1); // Part2
    fscanf((FILE*)buffer, "%i", "", 1); // Not detected
}

void part3() {}

void part4() {}

void part5() {}

int main() {
    part1();
    part2();
    part3();
    part4();
    part5();

    return 0;
}