cd /workspace/part4/part4_instrumentation/build/
cmake ..
make clean
make
cd ../DivZeroInstrument/test/

SRC=simple0

clang -emit-llvm -S -fno-discard-value-names -c -o $SRC.ll $SRC.c -g
opt -load ../../build/DivZeroInstrument/libInstrumentPass.so -Instrument -S $SRC.ll -o $SRC.instrumented.ll
clang -o $SRC -L../../build/DivZeroInstrument -lruntime $SRC.instrumented.ll
LD_LIBRARY_PATH=../../build/DivZeroInstrument ./$SRC

cd /workspace/part4
