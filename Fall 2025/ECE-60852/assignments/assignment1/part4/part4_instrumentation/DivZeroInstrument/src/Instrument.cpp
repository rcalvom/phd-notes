#include "Instrument.h"

using namespace llvm;

namespace instrument {

static const char *SanitizerFunctionName = "__sanitize__";
static const char *CoverageFunctionName = "__coverage__";

void instrumentSanitize(Module *M, Function &F, Instruction &I) {
    if (BinaryOperator *binary_operation = dyn_cast<BinaryOperator>(&I)) {
        if ((binary_operation->getOpcode() == Instruction::SDiv) ||
            (binary_operation->getOpcode() == Instruction::UDiv) ||
            (binary_operation->getOpcode() == Instruction::FDiv)) {
            Value *divisor = binary_operation->getOperand(1);

            auto void_type = Type::getVoidTy(M->getContext());
            auto integer_type = Type::getInt32Ty(M->getContext());

            auto sanitization_function_callback = M->getOrInsertFunction(
                "__sanitize__",
                FunctionType::get(void_type, {integer_type, integer_type, integer_type}, false));
            Function *sanitization_function =
                cast<Function>(dyn_cast<Constant>(sanitization_function_callback.getCallee()));

            DebugLoc debug_info = (&I)->getDebugLoc();
            Type *i32_type = IntegerType::getInt32Ty(M->getContext());
            Constant *row_arg = ConstantInt::get(i32_type, debug_info.getLine(), false);
            Constant *col_arg = ConstantInt::get(i32_type, debug_info.getCol(), false);

            IRBuilder<> builder(&I);

            CallInst *call = builder.CreateCall(sanitization_function, {divisor, row_arg, col_arg});
            call->setCallingConv(CallingConv::C);
            call->setTailCall(true);
        }
    }
}

void instrumentCoverage(Module *M, Function &F, Instruction &I) {
    auto void_type = Type::getVoidTy(M->getContext());
    auto integer_type = Type::getInt32Ty(M->getContext());
    auto coverage_function_callback = M->getOrInsertFunction(
        "__coverage__", FunctionType::get(void_type, {integer_type, integer_type}, false));
    Function *coverage_function =
        cast<Function>(dyn_cast<Constant>(coverage_function_callback.getCallee()));

    DebugLoc debug_info = (&I)->getDebugLoc();
    if (!debug_info) {
        return;
    }
    Type *i32_type = IntegerType::getInt32Ty(M->getContext());
    Constant *row_arg = ConstantInt::get(i32_type, debug_info.getLine(), false);
    Constant *col_arg = ConstantInt::get(i32_type, debug_info.getCol(), false);

    IRBuilder<> builder(&I);
    CallInst *call = builder.CreateCall(coverage_function, {row_arg, col_arg});
    call->setCallingConv(CallingConv::C);
    call->setTailCall(true);
}

bool Instrument::runOnFunction(Function &function) {
    for (auto &basic_block : function) {
        for (auto &instruction : basic_block) {
            instrumentCoverage(function.getParent(), function, instruction);
            instrumentSanitize(function.getParent(), function, instruction);
        }
    }
    return true;
}

char Instrument::ID = 1;
static RegisterPass<Instrument> X("Instrument", "Instrumentations for Dynamic Analysis", false,
                                  false);

} // namespace instrument
