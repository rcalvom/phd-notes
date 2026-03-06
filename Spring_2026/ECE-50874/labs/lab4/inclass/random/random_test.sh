#!/bin/bash

# 1. Setup
mkdir -p crashes

# Compile the target if it doesn't exist
# We use -fno-stack-protector so the buffer overflow actually crashes
if [ ! -f ./cmd_natural ]; then
    echo "Compiling target..."
    gcc -g -fno-stack-protector -z execstack cmd_natural.c -o cmd_natural
fi

echo "Starting fuzzer... Press Ctrl+C to stop."
count=0

while true; do
    # 2. Generate Input
    # We filter /dev/urandom for printable characters only.
    # This simulates a "dumb" text fuzzer.
    # We grab 64 bytes, which is enough to trigger the buffer overflow (16 bytes).
    cat /dev/urandom | tr -dc '[:print:]\n' | head -c 64 > input.txt

    # 3. Run Target
    # We redirect stdout/stderr to null to keep the screen clean.
    ./cmd_natural input.txt > /dev/null 2>&1
    exit_code=$?

    # 4. Check for Crash
    # 139 = Segmentation Fault (SIGSEGV)
    if [ $exit_code -eq 139 ]; then
        echo "(!) CRASH FOUND at iteration $count"
        
        # Print the input that caused it
        echo "Input: $(cat input.txt)"
        
        # Save the artifact
        cp input.txt "crashes/crash_$count.txt"
        
        # Optional: Stop after the first crash
        # break 
    fi

    # 5. Progress
    ((count++))
    if (( count % 500 == 0 )); then
        echo -ne "Iterations: $count\r"
    fi
done