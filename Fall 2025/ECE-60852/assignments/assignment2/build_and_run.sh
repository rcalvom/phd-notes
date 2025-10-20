#!/bin/bash
# Usage: sh file.sh branch0

if [ -z "$1" ]; then
  echo "Usage: sh $0 <source_basename>"
  exit 1
fi

SRC=$1

cd /workdir/LLVMBasedDSE || exit 1
mkdir -p build
cd build || exit 1
cmake LLVMBasedDSE ..
make clean
make
export LD_LIBRARY_PATH=/workdir/LLVMBasedDSE/build/DSE:$LD_LIBRARY_PATH

cd /workdir/LLVMBasedDSE/DSE/test || exit 1

rm -rf formula.smt2
rm -rf branch.txt
rm -rf input.txt
rm -rf log.txt
clang -emit-llvm -S -fno-discard-value-names -c $SRC.c
opt -load ../../build/DSE/libInstrumentPass.so -Instrument -S $SRC.ll -o $SRC.instrumented.ll
clang -o $SRC -L../../build/DSE -lruntime $SRC.instrumented.ll
#../../build/DSE/dse ./$SRC 2
timeout 10 ../../build/DSE/dse ./$SRC
