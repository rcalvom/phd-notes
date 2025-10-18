#include "Instrument.h"

using namespace llvm;

namespace instrument {

void instrument(const char *StringRef, Module *M, Instruction &I,
                llvm::ArrayRef<llvm::Type *> Params, llvm::ArrayRef<llvm::Value *> Args) {
    Type *VT = Type::getVoidTy(M->getContext());
    FunctionType *FT = FunctionType::get(VT, Params, false);
    FunctionCallee FC = M->getOrInsertFunction(StringRef, FT);
    CallInst *C = CallInst::Create(FC, Args, "", &I);
    C->setCallingConv(CallingConv::C);
}

void handleAllocationInstrumentation(AllocaInst *AI, Module *M, Instruction &I) {
    Type *IT = Type::getInt32Ty(M->getContext());
    Type *PT = PointerType::getUnqual(IT);
    Instruction *NI = I.getNextNode();
    instrument(DSEAllocaFunctionName, M, *NI, {IT, PT},
               {ConstantInt::get(IT, getRegisterID(&I), false), AI});
}

void handleStoreInstrumentation(StoreInst *SI, Module *M, Instruction &I) {
    Type *IT = Type::getInt32Ty(M->getContext());
    Type *PT = PointerType::get(Type::getInt32Ty(M->getContext()), SI->getPointerAddressSpace());
    if (ConstantInt *CI = dyn_cast<ConstantInt>(SI->getValueOperand())) {
        instrument(DSEConstFunctionName, M, I, {IT}, {CI});
    } else {
        Constant *CV = ConstantInt::get(IT, APInt(32, getRegisterID(&I)));
        instrument(DSERegisterFunctionName, M, I, {IT}, {CV});
    }
    instrument(DSEStoreFunctionName, M, I, {PT}, {SI->getPointerOperand()});
}

void handleLoadInstrumentation(LoadInst *LI, Module *M, Instruction &I) {
    Type *IT = Type::getInt32Ty(M->getContext());
    Type *PT = PointerType::getUnqual(IT);
    Constant *CV = ConstantInt::get(IT, APInt(32, getRegisterID(&I)));
    instrument(DSELoadFunctionName, M, I, {IT, PT}, {CV, LI->getPointerOperand()});
}
void handleCompareInstrumentation(CmpInst *CI, Module *M, Instruction &I) {
    Type *IT = Type::getInt32Ty(M->getContext());
    Value *OP1 = CI->getOperand(0);
    Value *OP2 = CI->getOperand(1);
    if (ConstantInt *CI1 = dyn_cast<ConstantInt>(OP1)) {
        instrument(DSEConstFunctionName, M, I, {IT}, {CI1});
    } else {
        Constant *CV = ConstantInt::get(IT, APInt(32, getRegisterID(OP1)));
        instrument(DSERegisterFunctionName, M, I, {IT}, {CV});
    }
    if (ConstantInt *CI2 = dyn_cast<ConstantInt>(OP2)) {
        instrument(DSEConstFunctionName, M, I, {IT}, {CI2});
    } else {
        Constant *CV = ConstantInt::get(IT, APInt(32, getRegisterID(OP2)));
        instrument(DSERegisterFunctionName, M, I, {IT}, {CV});
    }
    Constant *V = ConstantInt::get(IT, APInt(32, getRegisterID(&I)));
    Constant *PV = ConstantInt::get(IT, APInt(32, CI->getPredicate()));
    instrument(DSEICmpFunctionName, M, I, {IT, IT}, {V, PV});
}

void handleBinaryOperationInstrumentation(BinaryOperator *BO, Module *M, Instruction &I) {
    Type *IT = Type::getInt32Ty(M->getContext());
    Value *OP1 = BO->getOperand(0);
    Value *OP2 = BO->getOperand(1);
    if (ConstantInt *CI1 = dyn_cast<ConstantInt>(OP1)) {
        instrument(DSEConstFunctionName, M, I, {IT}, {CI1});
    } else {
        Constant *CV = ConstantInt::get(IT, APInt(32, getRegisterID(OP1)));
        instrument(DSERegisterFunctionName, M, I, {IT}, {CV});
    }
    if (ConstantInt *CI2 = dyn_cast<ConstantInt>(OP2)) {
        instrument(DSEConstFunctionName, M, I, {IT}, {CI2});
    } else {
        Constant *CV = ConstantInt::get(IT, APInt(32, getRegisterID(OP2)));
        instrument(DSERegisterFunctionName, M, I, {IT}, {CV});
    }
    Constant *V = ConstantInt::get(IT, APInt(32, getRegisterID(&I)));
    Constant *OCV = ConstantInt::get(IT, APInt(32, BO->getOpcode()));
    instrument(DSEBinOpFunctionName, M, I, {IT, IT}, {V, OCV});
}

void handleBranchInstrumentation(BranchInst *BI, Module *M, Instruction &I) {
    if (!BI->isConditional()) {
        return;
    }
    Type *IT = Type::getInt32Ty(M->getContext());
    Type *CT = Type::getInt1Ty(M->getContext());
    Constant *BIDV = ConstantInt::get(IT, APInt(32, getBranchID(&I)));
    Constant *IDV = ConstantInt::get(IT, APInt(32, getRegisterID(BI->getCondition())));
    Value *CV = BI->getCondition();
    instrument(DSEBranchFunctionName, M, I, {IT, IT, CT}, {BIDV, IDV, CV});
}

void instrumentInit(Module *M, Instruction &I) { instrument(DSEInitFunctionName, M, I, {}, {}); }

bool Instrument::runOnFunction(Function &F) {
    instrumentInit(F.getParent(), F.front().front());
    for (auto &BB : F) {
        for (auto &I : BB) {
            if (AllocaInst *AI = dyn_cast<AllocaInst>(&I)) {
                handleAllocationInstrumentation(AI, F.getParent(), I);
            } else if (StoreInst *SI = dyn_cast<StoreInst>(&I)) {
                handleStoreInstrumentation(SI, F.getParent(), I);
            } else if (LoadInst *LI = dyn_cast<LoadInst>(&I)) {
                handleLoadInstrumentation(LI, F.getParent(), I);
            } else if (CmpInst *CI = dyn_cast<CmpInst>(&I)) {
                handleCompareInstrumentation(CI, F.getParent(), I);
            } else if (BinaryOperator *BO = dyn_cast<BinaryOperator>(&I)) {
                handleBinaryOperationInstrumentation(BO, F.getParent(), I);
            } else if (BranchInst *BI = dyn_cast<BranchInst>(&I)) {
                handleBranchInstrumentation(BI, F.getParent(), I);
            }
        }
    }
    return true;
}

char Instrument::ID = 1;
static RegisterPass<Instrument> X("Instrument", "Instrumentations for Dynamic Symbolic Execution",
                                  false, false);

} // namespace instrument
