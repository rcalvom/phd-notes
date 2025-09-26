cd /workdir/part2/part2_basic_data_flow_analysis
mkdir -p build/
cd build
cmake part2_basic_data_flow_analysis .. 
make clean
make
cd ../DivZero/test/

SRC=simple1

clang -emit-llvm -S -fno-discard-value-names -Xclang -disable-O0-optnone -c $SRC.c
opt -mem2reg -S $SRC.ll -o $SRC.opt.ll
opt -load ../../build/DivZero/libDataflowPass.so -DivZero -disable-output $SRC.opt.ll
cd /workdir/part2
# Branch 1 // branch handling
# loop0