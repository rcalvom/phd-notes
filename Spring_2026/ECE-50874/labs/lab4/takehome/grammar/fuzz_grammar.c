#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

/*
 * Lab 4 (Take Home)
 * ------------------------------------
 * Students fill in the helper routines to transform arbitrary fuzzer input
 * into structured commands that exercise the server implemented in target.c.
 * Each helper should be implemented safely (respecting buffer sizes and
 * avoiding undefined behavior). Inline comments outline the intended logic.
 */

/* Provided by target.c when linking the final harness. */
void process_line(char *input);

/* Allowed characters when building printable tokens. */
static const char kAlphaNum[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-";

/*
 * Maps a slice of fuzzer data into a safe, printable token.
 * - data/size describe the raw fuzzer buffer.
 * - offset points to the current read position and must be advanced.
 * - out/out_cap is the destination buffer (null-terminate on success).
 * Returns the number of bytes written to `out` (excluding the terminator).
 */
static size_t consume_token(const uint8_t *data, size_t size, size_t *offset,
                            char *out, size_t out_cap) {
    /*
     * TODO implementation steps:
     * 1) If *offset is already past size or out_cap is 0, return 0 immediately.
     * 2) Compute how many bytes remain: remaining = size - *offset.
     * 3) Limit the copy to at most out_cap - 1 bytes so we can null-terminate.
     * 4) For each byte to copy, map it into kAlphaNum using modulo to avoid
     *    non-printable characters.
     * 5) Write a trailing '\0'.
     * 6) Advance *offset by the number of bytes consumed and return that count.
     */
    (void)data;
    (void)size;
    (void)offset;
    (void)out;
    (void)out_cap;
    return 0; /* placeholder to keep the scaffold compiling */
}

/*
 * Builds a small integer (possibly negative) from fuzzer data.
 * - Start with a sign bit from the next byte.
 * - Accumulate up to a few digits (base-10) from subsequent bytes.
 * Returns the constructed integer and advances offset accordingly.
 */
static int consume_number(const uint8_t *data, size_t size, size_t *offset) {
    /*
     * TODO implementation steps:
     * 1) If *offset >= size, return 0 (no bytes left).
     * 2) Read sign from data[*offset] (odd => negative, even => positive), then ++*offset.
     * 3) Initialize value = 0 and a digit counter.
     * 4) While *offset < size and you have not exceeded 4 digits:
     *      - value = value * 10 + (data[*offset] % 10);
     *      - increment *offset and digit counter.
     * 5) Return sign * value.
     */
    (void)data;
    (void)size;
    (void)offset;
    return 0; /* placeholder */
}

/*
 * Appends a literal C-string to the line buffer without overflow.
 * - buf/len/cap describe the destination buffer and current length.
 * - lit is a null-terminated source string.
 * Returns the updated length (len may be unchanged if the buffer is full).
 */
static size_t append_literal(char *buf, size_t len, size_t cap, const char *lit) {
    /*
     * TODO implementation steps:
     * 1) If len >= cap, buffer is full; return len unchanged.
     * 2) While *lit is non-zero and len + 1 < cap (reserve room for '\0'):
     *      - buf[len] = *lit;
     *      - ++len; ++lit;
     * 3) Return the updated len (caller will add terminator if needed).
     */
    (void)buf;
    (void)len;
    (void)cap;
    (void)lit;
    return len; /* placeholder */
}

/*
 * Appends a pre-sanitized token to the line buffer without overflow.
 * Behavior mirrors append_literal but sources bytes from `tok`.
 */
static size_t append_token(char *buf, size_t len, size_t cap, const char *tok) {
    /*
     * TODO implementation steps:
     * 1) Mirror append_literal but source characters from `tok`.
     * 2) Stop when tok hits '\0' or len + 1 reaches cap.
     * 3) Return the updated len.
     */
    (void)buf;
    (void)len;
    (void)cap;
    (void)tok;
    return len; /* placeholder */
}

/*
 * Entry point used by libFuzzer.
 * Build a single line command based on the first byte (selector) and the
 * remaining bytes, then forward it to process_line for execution.
 */
int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    /* Early exit on empty input to avoid touching data[0]. */
    if (size == 0) return 0;

    char line[256];      /* Output buffer for the constructed command. */
    size_t len = 0;      /* Tracks how many bytes currently populate `line`. */
    size_t offset = 0;   /* Tracks how many bytes have been consumed from input. */

    /* First byte selects the command family. Keep this byte consumed. */
    uint8_t selector = data[offset++];
    uint8_t branch = selector % 5; /* 0-4 map to ECHO, LOGIN, RESERVE, TRANSFER, LOGOUT */

    if (branch == 0) {
        /* ECHO: optionally include an argument token. */
        len = append_literal(line, len, sizeof(line), "ECHO");
        if (offset < size && (data[offset] % 2)) {
            len = append_literal(line, len, sizeof(line), " ");
            char token[64];
            consume_token(data, size, &offset, token, sizeof(token));
            len = append_token(line, len, sizeof(line), token);
        }
    } else if (branch == 1) {
        /* LOGIN: username token with user-controlled length to stress copies. */
        len = append_literal(line, len, sizeof(line), "LOGIN ");
        char token[128];
        consume_token(data, size, &offset, token, sizeof(token));
        len = append_token(line, len, sizeof(line), token);
    } else if (branch == 2) {
        /* RESERVE: numeric argument may be negative or oversized. */
        len = append_literal(line, len, sizeof(line), "RESERVE ");
        int number = consume_number(data, size, &offset);
        char num_buf[32];
        snprintf(num_buf, sizeof(num_buf), "%d", number);
        len = append_token(line, len, sizeof(line), num_buf);
    } else if (branch == 3) {
        /* TRANSFER: from:to:amount pattern. */
        len = append_literal(line, len, sizeof(line), "TRANSFER ");

        char from[48];
        char to[48];
        consume_token(data, size, &offset, from, sizeof(from));
        consume_token(data, size, &offset, to, sizeof(to));
        int amount = consume_number(data, size, &offset);

        len = append_token(line, len, sizeof(line), from);
        len = append_literal(line, len, sizeof(line), ":");
        len = append_token(line, len, sizeof(line), to);
        len = append_literal(line, len, sizeof(line), ":");

        char amt_buf[32];
        snprintf(amt_buf, sizeof(amt_buf), "%d", amount);
        len = append_token(line, len, sizeof(line), amt_buf);
    } else {
        /* LOGOUT: no arguments. */
        len = append_literal(line, len, sizeof(line), "LOGOUT");
    }

    /* Always null-terminate and append a trailing newline when space permits. */
    if (len + 1 < sizeof(line)) {
        line[len++] = '\n';
    }
    line[len] = '\0';

    /* Forward the constructed command to the target for processing. */
    process_line(line);
    return 0;
}
