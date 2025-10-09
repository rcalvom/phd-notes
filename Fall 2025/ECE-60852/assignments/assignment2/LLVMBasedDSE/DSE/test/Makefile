.PRECIOUS: %.ll %.instrumented.ll

TARGETS=simple0 simple1 infeasable branch0 branch1 branch2

all: ${TARGETS}

%: %.c
	clang -emit-llvm -S -fno-discard-value-names -c -o $@.ll $<
	opt -load ../../build/DSE/libInstrumentPass.so -Instrument -S $*.ll -o $*.instrumented.ll
	clang -o $@ -L${PWD}/../../build/DSE -lruntime $*.instrumented.ll

clean:
	rm -f *.ll *.out *.err *.smt2 input.txt branch.txt ${TARGETS}
