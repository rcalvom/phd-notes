#!/bin/bash
# Usage: sh file_part4.sh simple0

if [ -z "$1" ]; then
  echo "Usage: sh $0 <source_basename>"
  exit 1
fi

SRC=$1

# Go to build dir and rebuild
cd /workdir/part4/part4_instrumentation || exit 1
mkdir -p build
cd build || exit 1
cmake ..
make clean
make

# Go to test dir
cd ../DivZeroInstrument/test || exit 1

# Compile C to LLVM IR with debug info
clang -emit-llvm -S -fno-discard-value-names -c -o "$SRC.ll" "$SRC.c" -g

# Run instrumentation pass
opt -load ../../build/DivZeroInstrument/libInstrumentPass.so -Instrument -S "$SRC.ll" -o "$SRC.instrumented.ll"

# Link with runtime
clang -o "$SRC" -L../../build/DivZeroInstrument -lruntime "$SRC.instrumented.ll"

# Run executable with runtime lib
LD_LIBRARY_PATH=../../build/DivZeroInstrument ./"$SRC"

# Return to root
cd /workdir/part4 || exit 1
