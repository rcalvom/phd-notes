cd /workspace/part2/part2_basic_data_flow_analysis/build/
cmake -DUSE_REFERENCE=ON ..
make clean
make
cd ../DivZero/test/

SRC=branch3

clang -emit-llvm -S -fno-discard-value-names -Xclang -disable-O0-optnone -c $SRC.c
opt -mem2reg -S $SRC.ll -o $SRC.opt.ll
opt -load ../../build/DivZero/libDataflowPass.so -DivZero -disable-output $SRC.opt.ll

cd /workspace/part2
