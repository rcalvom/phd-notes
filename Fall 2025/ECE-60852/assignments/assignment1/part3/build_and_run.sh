#!/bin/bash
# Usage: sh file_part3.sh pointer4

if [ -z "$1" ]; then
  echo "Usage: sh $0 <source_basename>"
  exit 1
fi

SRC=$1

# Go to build dir and rebuild
cd /workdir/part3/part3_pointer_aware_data_flow_analysis || exit 1
mkdir -p build
cd build || exit 1
cmake ..
make clean
make

# Go to test dir
cd ../DivZero/test || exit 1

# Compile C to LLVM IR
clang -emit-llvm -S -fno-discard-value-names -Xclang -disable-O0-optnone -c "$SRC.c" -o "$SRC.opt.ll"

# Run analysis pass
opt -load ../../build/DivZero/libDataflowPass.so -DivZero "$SRC.opt.ll"

# Return to root
cd /workdir/part3 || exit 1
# branch3
# branch6
# pointer4