#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// --- HELPER ---
void strip_newline(char *str) {
    str[strcspn(str, "\n")] = 0;
}

// --- COMMAND HANDLER ---
void process_line(char *input) {
    strip_newline(input);

    // Tokenize: Get the Command (e.g., "E")
    char *cmd = strtok(input, " ");
    
    // SAFETY CHECK: Handle empty lines
    if (!cmd) return;
    char *arg = strtok(NULL, " ");

    // Step 2: Change to E -> ECHO
    if (strcmp(cmd, "ECHO") == 0) {
        printf("%s\n", arg); 
    }
    // Step 2: Change to L -> LOGIN
    else if (strcmp(cmd, "LOGIN") == 0) {
        if (!arg) return;

        char username[16];
        
        strcpy(username, arg); 
        
        printf("User %s logged in.\n", username);
    }

    // Step 2: Change to R -> RESERVE
    else if (strcmp(cmd, "RESERVE") == 0) {
        if (!arg) return;

        int size = atoi(arg);

        if (size > 1000) {
            printf("Error: Too much memory requested.\n");
            return;
        }

        printf("Reserving %d bytes...\n", size);
        char *buffer = malloc(size); 
        
        if (buffer) {
            memset(buffer, 'A', size);
            printf("Success.\n");
            free(buffer);
        } else {

            printf("Allocation failed (System OOM).\n");
        }
    }
    else {
        printf("Unknown command: %s\n", cmd);
    }
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 0;
    }

    FILE *f = fopen(argv[1], "rb");
    if (!f) return 1;

    char buffer[256];
    // Read one line from the file
    if (fgets(buffer, sizeof(buffer), f)) {
        process_line(buffer);
    }
    
    fclose(f);
    return 0;
}