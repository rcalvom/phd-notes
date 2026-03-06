#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

/* ---------- Helpers ---------- */

void strip_newline(char *str) {
    str[strcspn(str, "\n")] = 0;
}

/* ---------- Shallow Bug (NULL Dereference) ---------- */
/* Trigger: "ECHO" style behavior but argument missing */

void handle_echo(char *arg) {
    printf("%s\n", arg);   // BUG: arg may be NULL
}

/* ---------- LOGIN Branch ---------- */
/* Potential stack overflow via strcpy */

void handle_login(char *arg) {
    if (!arg) return;

    char username[24];

    strcpy(username, arg); // BUG: unbounded copy

    printf("LOGIN SUCCESS %s\n", username);
}

/* ---------- RESERVE Branch (Deeper Bug) ---------- */
/* Signedness + allocation logic */

void handle_reserve(char *arg) {
    if (!arg) return;

    int size = atoi(arg);

    if (size > 2048) {
        printf("Too large request\n");
        return;
    }

    /* BUG: malloc expects size_t (unsigned) */
    char *buf = malloc((size_t)size);

    if (!buf) {
        printf("Allocation failed\n");
        return;
    }

    memset(buf, 'A', size);
    free(buf);
}

/* ---------- Structured Input Bug (TRANSFER) ---------- */
/*
Expected format:
TRANSFER from:to:amount
Example:
TRANSFER alice:bob:100
*/

void handle_transfer(char *arg) {
    if (!arg) return;

    char *from = strtok(arg, ":");
    char *to = strtok(NULL, ":");
    char *amount_str = strtok(NULL, ":");

    if (!from || !to || !amount_str) {
        printf("Malformed transfer\n");
        return;
    }

    int amount = atoi(amount_str);

    /* BUG: No validation of amount */
    if (amount < 0 || amount > 5000) {
        printf("Transfer rejected\n");
        return;
    }

    printf("TRANSFER OK %s -> %s : %d\n", from, to, amount);
}

/* ---------- Command Dispatcher ---------- */

void process_line(char *input) {
    strip_newline(input);

    char *cmd = strtok(input, " ");
    if (!cmd) return;

    char *arg = strtok(NULL, "");

    if (strcmp(cmd, "ECHO") == 0) {
        /* Shallow bug path */
        handle_echo(arg);
    }
    else if (strcmp(cmd, "LOGIN") == 0) {
        handle_login(arg);
    }
    else if (strcmp(cmd, "RESERVE") == 0) {
        handle_reserve(arg);
    }
    else if (strcmp(cmd, "TRANSFER") == 0) {
        handle_transfer(arg);
    }
    else if (strcmp(cmd, "LOGOUT") == 0) {
        printf("LOGOUT OK\n");
    }
    else {
        printf("Unknown command: %s\n", cmd);
    }
}

/* ---------- Main ---------- */

#ifndef FUZZING
int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 0;
    }

    FILE *f = fopen(argv[1], "rb");
    if (!f) return 1;

    char buffer[256];

    if (fgets(buffer, sizeof(buffer), f)) {
        process_line(buffer);
    }

    fclose(f);
    return 0;
}
#endif /* FUZZING */