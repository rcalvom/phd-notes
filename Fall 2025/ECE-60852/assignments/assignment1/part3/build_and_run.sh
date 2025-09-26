cd /workdir/part3/part3_pointer_aware_data_flow_analysis
mkdir -p build/
cd build
cmake ..
make clean
make
cd ../DivZero/test/

SRC=pointer0

clang -emit-llvm -S -fno-discard-value-names -Xclang -disable-O0-optnone -c $SRC.c -o $SRC.opt.ll
opt -load ../../build/DivZero/libDataflowPass.so -DivZero $SRC.opt.ll

cd /workdir/part3
