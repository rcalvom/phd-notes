#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

// --- THE NATURAL BARRIER ---
const char *PROTOCOL_HEADER = "PROT_V1:";

void process_line(char *input) {
    // 1. PROTOCOL CHECK
    if (strncmp(input, PROTOCOL_HEADER, strlen(PROTOCOL_HEADER)) != 0) {
        return;
    }

    // 2. PARSING
    char *payload = input + strlen(PROTOCOL_HEADER); 
    payload[strcspn(payload, "\n")] = 0; // Strip newline

    // Get the Command
    char *cmd = strtok(payload, " ");
    if (!cmd) return;

    // Get the Argument
    char *arg = strtok(NULL, " ");

    // --- COMMAND ROUTING ---

    // 1. PING
    // Simply responds "PONG".
    if (strcmp(cmd, "PING") == 0) {
        printf("PONG\n");
    }

    // 2. ECHO
    else if (strcmp(cmd, "ECHO") == 0) {
        if (arg && arg[0] == '!') {
            printf("Echo: %s\n", arg);
        }
    }

    // 3. VERSION
    else if (strcmp(cmd, "VERSION") == 0) {
        printf("Protocol v1.2 (Build 2026-02-24)\n");
    }

    // 4. LOGIN
    else if (strcmp(cmd, "LOGIN") == 0) {
        if (!arg) {
            printf("Error: Username required.\n");
            return;
        }
        
        volatile char username[16];
        strncpy((char*)username, arg, sizeof(username) - 1);
        username[sizeof(username) - 1] = '\0';

        printf("Login success: %s\n", (char*)username);
    }

    // 5. STATUS
    else if (strcmp(cmd, "STATUS") == 0) {
        if (arg && strcmp(arg, "FULL") == 0) {
            printf("System Status: OPERATIONAL (Load: 12%%, Mem: 4GB)\n");
        } else {
            printf("System: OK\n");
        }
    }

    // 6. RESERVE
    else if (strcmp(cmd, "RESERVE") == 0) {
        if (!arg) return;
        
        int idx = atoi(arg);

        if (idx >= 0 && idx < 100) {
            static volatile char buffer[100];
            
            buffer[idx] = 'X'; 
            (void)buffer[idx];
            printf("Reserved slot %d.\n", idx);
        } else {
            printf("Error: Invalid slot index.\n");
        }
    }

    // Default handler
    else {
        printf("Unknown command: %s\n", cmd);
    }
}

// --- HARNESS ---
int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
    // Safety check for empty inputs
    if (Size == 0) return 0;

    // Convert raw bytes to C-string
    char *str = malloc(Size + 1);
    if (!str) return 0;
    memcpy(str, Data, Size);
    str[Size] = '\0';

    process_line(str);

    free(str);
    return 0;
}
