#include <iostream>

#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instruction.h"

#include "SymbolicInterpreter.h"

using namespace llvm;

extern SymbolicInterpreter SI;

z3::expr evaluate_input(z3::expr &Expr) {
    if (Expr.kind() == Z3_NUMERAL_AST) {
        return Expr;
    }
    MemoryTy Mem = SI.getMemory();
    Address Addr(Expr);
    if (SI.getMemory().find(Addr) != SI.getMemory().end()) {
        return SI.getMemory().at(Addr);
    }
    return Expr;
}

extern "C" void __DSE_Alloca__(int R, int *Ptr) {
    Address Addr(R);
    z3::expr Expr = SI.getContext().int_val(reinterpret_cast<uintptr_t>(Ptr));
    SI.getMemory().erase(Addr);
    SI.getMemory().insert(std::make_pair(Addr, Expr));
}

extern "C" void __DSE_Store__(int *X) {
    Address Addr(X);
    z3::expr Expr = evaluate_input(SI.getStack().top());
    SI.getStack().pop();
    SI.getMemory().erase(Addr);
    SI.getMemory().insert(std::make_pair(Addr, Expr));
}

extern "C" void __DSE_Load__(int Y, int *X) {
    Address Addr(Y);
    z3::expr Expr(SI.getContext());
    if (SI.getInputs().find(Y) != SI.getInputs().end()) {
        Expr = SI.getContext().int_val(SI.getInputs().at(Y));
    } else {
        Expr = SI.getMemory().at(Address(X));
    }
    SI.getMemory().erase(Addr);
    SI.getMemory().insert(std::make_pair(Addr, Expr));
}

extern "C" void __DSE_ICmp__(int R, int Op) {
    z3::expr O2 = evaluate_input(SI.getStack().top());
    SI.getStack().pop();
    z3::expr O1 = evaluate_input(SI.getStack().top());
    SI.getStack().pop();
    Address Addr(R);
    z3::expr Expr(SI.getContext());
    switch (Op) {
        case CmpInst::ICMP_EQ: {
            Expr = (O1 == O2);
            break;
        }
        case CmpInst::ICMP_NE: {
            Expr = (O1 != O2);
            break;
        }
        case CmpInst::ICMP_SGE:
        case CmpInst::ICMP_UGE: {
            Expr = (O1 >= O2);
            break;
        }
        case CmpInst::ICMP_SLE:
        case CmpInst::ICMP_ULE: {
            Expr = (O1 <= O2);
            break;
        }
        case CmpInst::ICMP_SGT:
        case CmpInst::ICMP_UGT: {
            Expr = (O1 > O2);
            break;
        }
        case CmpInst::ICMP_SLT:
        case CmpInst::ICMP_ULT: {
            Expr = (O1 < O2);
            break;
        }
    }
    SI.getMemory().erase(Addr);
    SI.getMemory().insert(std::make_pair(Addr, Expr));
}

extern "C" void __DSE_BinOp__(int R, int Op) {
    z3::expr O2 = evaluate_input(SI.getStack().top());
    SI.getStack().pop();
    z3::expr O1 = evaluate_input(SI.getStack().top());
    SI.getStack().pop();

    Address Addr(R);
    z3::expr Expr(SI.getContext());
    switch (Op) {
        case Instruction::Add: {
            Expr = O1 + O2;
            break;
        }
        case Instruction::Sub: {
            Expr = O1 - O2;
            break;
        }
        case Instruction::Mul:
            Expr = O1 * O2;
            break;
        case Instruction::SDiv:
        case Instruction::UDiv: {
            Expr = O1 / O2;
            break;
        }
    }
    SI.getMemory().erase(Addr);
    SI.getMemory().insert(std::make_pair(Addr, Expr));
}
