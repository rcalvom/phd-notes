#!/bin/bash
# Usage: sh file.sh branch0

if [ -z "$1" ]; then
  echo "Usage: sh $0 <source_basename>"
  exit 1
fi

SRC=$1

# Go to build dir and rebuild
cd /workdir/part2/part2_basic_data_flow_analysis || exit 1
mkdir -p build
cd build || exit 1
cmake part2_basic_data_flow_analysis ..
make clean
make

# Go to test dir
cd ../DivZero/test || exit 1

# Compile C to LLVM IR
clang -emit-llvm -S -fno-discard-value-names -Xclang -disable-O0-optnone -c "$SRC.c" -o "$SRC.ll"

# Optimize IR
opt -mem2reg -S "$SRC.ll" -o "$SRC.opt.ll"

# Run analysis pass
opt -load ../../build/DivZero/libDataflowPass.so -DivZero -disable-output "$SRC.opt.ll"
