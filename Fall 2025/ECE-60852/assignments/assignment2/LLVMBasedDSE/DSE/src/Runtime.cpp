#include <iostream>

#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instruction.h"

#include "SymbolicInterpreter.h"

using namespace llvm;

extern SymbolicInterpreter SI;

void printMap(const std::map<Address, z3::expr> &m) {
    for (const auto &pair : m) {
        std::cout << pair.first << " => " << pair.second.to_string() << std::endl;
    }
}
void print_map(const std::map<int, int> &myMap) {
    for (const auto &pair : myMap) {
        std::cout << "Key: " << pair.first << ", Value: " << pair.second << std::endl;
    }
}

extern "C" void __DSE_Alloca__(int R, int *Ptr) {
    Address Addr(R);
    
    // std::cout << "Alloca" << std::endl;
    // Address X(R);
    // uintptr_t address = reinterpret_cast<uintptr_t>(Ptr);
    // z3::expr Z = SI.getContext().int_val(address);
    // SI.getMemory().erase(X);
    // std::cout << "Allocing A, E " << X << " " << Z.to_string() << std::endl;
    // SI.getMemory().insert(std::make_pair(X, Z));
    // printMap(SI.getMemory());
    // print_map(SI.getInputs());
}

extern "C" void __DSE_Store__(int *X) {
    uintptr_t address = reinterpret_cast<uintptr_t>(X);
    std::cout << "Store, pointer: " << address << std::endl;
    Address A(X);
    z3::expr E = SI.getStack().top();
    SI.getStack().pop();
    SI.getMemory().erase(A);

    try {
        Address Another(E);
        std::cout << "got another: " << E.to_string() << std::endl;
        z3::expr E2 = SI.getMemory().at(Another);
        std::cout << "storing A, E2 " << A << " " << E2.to_string() << std::endl;
        SI.getMemory().insert(std::make_pair(A, E2));
    } catch (...) {
        std::cout << "not using another " << std::endl;
        std::cout << "Storing A, E " << A << " " << E.to_string() << std::endl;
        SI.getMemory().insert(std::make_pair(A, E));
    }

    printMap(SI.getMemory());
    print_map(SI.getInputs());
}

extern "C" void __DSE_Load__(int Y, int *X) {
    std::cout << "Load" << std::endl;
    Address A(Y);
    z3::expr E = SI.getMemory().at(Address(X));

    // std::cout << "to string: " << E.to_string() << std::endl;
    // Address Another(E);
    // z3::expr E2 = SI.getMemory().at(Another);

    std::cout << "Loadin A, E " << A << " " << E.to_string() << std::endl;
    SI.getMemory().erase(A);
    SI.getMemory().insert(std::make_pair(A, E));
    printMap(SI.getMemory());
    print_map(SI.getInputs());
}

extern "C" void __DSE_ICmp__(int R, int Op) { // the two parameters should be on the stack
    // Op is the opcode (Add, Sub, Divide)
    // R is the Register that we are going to add as a result of this binary operation
    std::cout << "ICMP" << std::endl;

    Address A(R);
    // TODO: may need to switch these around?
    std::cout << "stack: " << SI.getStack().top() << std::endl;
    z3::expr O2(SI.getContext());
    if (SI.getStack().top().is_numeral()) {
        O2 = SI.getStack().top();
    } else {
        z3::expr first = SI.getStack().top();
        Address firstA(first);
        O2 = SI.getMemory().at(firstA);
    }
    SI.getStack().pop();

    std::cout << "stack: " << SI.getStack().top() << std::endl;
    z3::expr O1(SI.getContext());
    if (SI.getStack().top().is_numeral()) {
        O1 = SI.getStack().top();
    } else {
        z3::expr first = SI.getStack().top();
        Address firstA(first);
        O1 = SI.getMemory().at(firstA);
    }
    SI.getStack().pop();

    z3::expr Result(SI.getContext());
    switch (Op) {
        case CmpInst::ICMP_EQ:
            Result = O1 == O2;
            break;
        case CmpInst::ICMP_NE:
            Result = O1 != O2;
            break;
        case CmpInst::ICMP_SGE:
        case CmpInst::ICMP_UGE:
            Result = O1 >= O2;
            break;
        case CmpInst::ICMP_SLE:
        case CmpInst::ICMP_ULE:
            Result = O1 <= O2;
            break;
        case CmpInst::ICMP_SGT:
        case CmpInst::ICMP_UGT:
            Result = O1 > O2;
            break;
        case CmpInst::ICMP_SLT:
        case CmpInst::ICMP_ULT:
            Result = O1 < O2;
            break;
    }

    SI.getMemory().erase(A);
    std::cout << "Storing A, E " << A << " " << Result.to_string() << std::endl;
    SI.getMemory().insert(std::make_pair(A, Result));
    std::cout << "inserted result" << std::endl;

    printMap(SI.getMemory());
    print_map(SI.getInputs());
}

extern "C" void __DSE_BinOp__(int R, int Op) {
    std::cout << "BinOp" << std::endl;

    Address A(R);
    std::cout << "stack: " << SI.getStack().top() << std::endl;
    z3::expr O2(SI.getContext());
    if (SI.getStack().top().is_numeral()) {
        O2 = SI.getStack().top();
    } else {
        z3::expr first = SI.getStack().top();
        Address firstA(first);
        O2 = SI.getMemory().at(firstA);
    }
    SI.getStack().pop();

    std::cout << "stack: " << SI.getStack().top() << std::endl;
    z3::expr O1(SI.getContext());
    if (SI.getStack().top().is_numeral()) {
        O1 = SI.getStack().top();
    } else {
        z3::expr first = SI.getStack().top();
        Address firstA(first);
        O1 = SI.getMemory().at(firstA);
    }
    SI.getStack().pop();

    z3::expr Result(SI.getContext());
    switch (Op) {
        case Instruction::Add:
            Result = O1 + O2;
            break;
        case Instruction::Sub:
            Result = O1 - O2;
            break;
        case Instruction::Mul:
            Result = O1 * O2;
            break;
        case Instruction::SDiv:
        case Instruction::UDiv:
            Result = O1 / O2;
            break;
    }

    std::cout << "Adding result to map: " << Result << std::endl;
    SI.getMemory().erase(A);
    std::cout << "Storing A, E " << A << " " << Result.to_string() << std::endl;
    SI.getMemory().insert(std::make_pair(A, Result));
    printMap(SI.getMemory());
    print_map(SI.getInputs());
}
