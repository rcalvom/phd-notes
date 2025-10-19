#include <iostream>

#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instruction.h"

#include "SymbolicInterpreter.h"

using namespace llvm;

extern SymbolicInterpreter SI;

extern "C" void __DSE_Alloca__(int R, int *Ptr) {
    std::cout << "Allocation" << std::endl;
    Address Addr(R);
    z3::expr Expr = SI.getContext().int_val(reinterpret_cast<uintptr_t>(Ptr));
    SI.getMemory().erase(Addr);
    SI.getMemory().insert(std::make_pair(Addr, Expr));
    std::cout << "[" << Addr << "] -> " << Expr.to_string() << std::endl;
    std::cout << "Memories: " << std::endl;
    for (const auto &pair : SI.getMemory()) {
        std::cout << "[" << pair.first << "] -> " << pair.second.to_string() << std::endl;
    }
    std::cout << "Inputs: " << std::endl;
    for (const auto &pair : SI.getInputs()) {
        std::cout << "[" << pair.first << "] -> " << pair.second << std::endl;
    }
    std::cout << std::endl;
}

extern "C" void __DSE_Store__(int *X) {
    std::cout << "Store" << std::endl;
    Address Addr(X);
    z3::expr Expr = SI.getStack().top();
    SI.getStack().pop();
    SI.getMemory().erase(Addr);
    SI.getMemory().insert(std::make_pair(Addr, Expr));
    std::cout << "[" << Addr << "] -> " << Expr.to_string() << std::endl;
    std::cout << "Memories: " << std::endl;
    for (const auto &pair : SI.getMemory()) {
        std::cout << "[" << pair.first << "] -> " << pair.second.to_string() << std::endl;
    }
    std::cout << "Inputs: " << std::endl;
    for (const auto &pair : SI.getInputs()) {
        std::cout << "[" << pair.first << "] -> " << pair.second << std::endl;
    }
    std::cout << std::endl;
}

extern "C" void __DSE_Load__(int Y, int *X) {
    std::cout << "Load" << std::endl;

    Address Addr(Y);
    z3::expr Expr = SI.getMemory().at(Address(X));
    SI.getMemory().erase(Addr);
    SI.getMemory().insert(std::make_pair(Addr, Expr));

    std::cout << "[" << Addr << "] -> " << Expr.to_string() << std::endl;
    std::cout << "Memories: " << std::endl;
    for (const auto &pair : SI.getMemory()) {
        std::cout << "[" << pair.first << "] -> " << pair.second.to_string() << std::endl;
    }
    std::cout << "Inputs: " << std::endl;
    for (const auto &pair : SI.getInputs()) {
        std::cout << "[" << pair.first << "] -> " << pair.second << std::endl;
    }
    std::cout << std::endl;
}

extern "C" void __DSE_ICmp__(int R, int Op) {
    std::cout << "Compare instruction" << std::endl;

    z3::expr O2 = SI.getStack().top();
    SI.getStack().pop();
    z3::expr O1 = SI.getStack().top();
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
    
    std::cout << "[" << Addr << "] -> " << Expr.to_string() << std::endl;
    std::cout << "Memories: " << std::endl;
    for (const auto &pair : SI.getMemory()) {
        std::cout << "[" << pair.first << "] -> " << pair.second.to_string() << std::endl;
    }
    std::cout << "Inputs: " << std::endl;
    for (const auto &pair : SI.getInputs()) {
        std::cout << "[" << pair.first << "] -> " << pair.second << std::endl;
    }
    std::cout << std::endl;
}

extern "C" void __DSE_BinOp__(int R, int Op) {
    std::cout << "BinaryOperation" << std::endl;

    z3::expr O2 = SI.getStack().top();
    SI.getStack().pop();
    z3::expr O1 = SI.getStack().top();
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
    
    std::cout << "[" << Addr << "] -> " << Expr.to_string() << std::endl;
    std::cout << "Memories: " << std::endl;
    for (const auto &pair : SI.getMemory()) {
        std::cout << "[" << pair.first << "] -> " << pair.second.to_string() << std::endl;
    }
    std::cout << "Inputs: " << std::endl;
    for (const auto &pair : SI.getInputs()) {
        std::cout << "[" << pair.first << "] -> " << pair.second << std::endl;
    }
    std::cout << std::endl;
}
