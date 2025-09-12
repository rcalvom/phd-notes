#include "DivZeroAnalysis.h"

using namespace std;

namespace dataflow {

// TODO:
// - Compare for constant values, no domains
// - Branches
// - Phi Nodes

//===----------------------------------------------------------------------===//
// DivZero Analysis Implementation
//===----------------------------------------------------------------------===//

/**
 * Implement your data-flow analysis.
 * 1. Define "flowIn" that joins the memory set of all incoming flows
 * 2. Define "transfer" that computes the semantics of each instruction.
 * 3. Define "flowOut" that flows the memory set to all outgoing flows
 * 4. Define "doAnalysis" that stores your results in "InMap" and "OutMap".
 * 5. Define "check" that checks if a given instruction is erroneous or not.
 */

Memory *join(Memory *M1, Memory *M2) {
    Memory *result = new Memory();
    for (auto it1 = M1->begin(); it1 != M1->end(); ++it1) {
        const auto &key = it1->first;
        Domain *val1 = it1->second;
        auto it = M2->find(key);
        if (it != M2->end()) {
            Domain *joined = Domain::join(val1, it->second);
            (*result)[key] = joined;
        } else {
            (*result)[key] = new Domain(*val1);
        }
    }
    for (auto it2 = M2->begin(); it2 != M2->end(); ++it2) {
        const auto &key = it2->first;
        Domain *val2 = it2->second;

        if (result->find(key) == result->end()) {
            (*result)[key] = new Domain(*val2);
        }
    }
    return result;
}

bool equal(Memory *M1, Memory *M2) {
    if (M1->size() != M2->size()) {
        return false;
    }
    for (auto it1 = M1->begin(); it1 != M1->end(); ++it1) {
        const auto &key = it1->first;
        Domain *val1 = it1->second;
        auto it = M2->find(key);
        if (it == M2->end()) {
            return false;
        }
        Domain *val2 = it->second;
        if (val1->Value != val2->Value) {
            return false;
        }
    }
    return true;
}

void DivZeroAnalysis::flowIn(Instruction *I, Memory *In) {
    auto predecessors = getPredecessors(I);
    for (auto *predecesor : predecessors) {
        In = join(In, OutMap[predecesor]);
    }
    InMap[I] = In;
}

void handleBinaryOperator(BinaryOperator *binary_operation, const Memory *In, Memory *NOut) {
    Domain *result = nullptr;
    Domain *left_domain = nullptr;
    Domain *right_domain = nullptr;
    Value *left_operand = binary_operation->getOperand(0);
    if (ConstantInt *left_constant = dyn_cast<ConstantInt>(left_operand)) {
        left_domain = new Domain(left_constant->isZero() ? Domain::Zero : Domain::NonZero);
    } else {
        auto it = In->find(variable(left_operand));
        left_domain = (it != In->end()) ? it->second : new Domain(Domain::Uninit);
    }
    Value *right_operand = binary_operation->getOperand(1);
    if (ConstantInt *right_constant = dyn_cast<ConstantInt>(right_operand)) {
        right_domain = new Domain(right_constant->isZero() ? Domain::Zero : Domain::NonZero);
    } else {
        auto it = In->find(variable(right_operand));
        right_domain = (it != In->end()) ? it->second : new Domain(Domain::Uninit);
    }
    switch (binary_operation->getOpcode()) {
        case Instruction::Add: {
            result = Domain::add(left_domain, right_domain);
            break;
        }
        case Instruction::Sub: {
            result = Domain::sub(left_domain, right_domain);
            break;
        }
        case Instruction::Mul: {
            result = Domain::mul(left_domain, right_domain);
            break;
        }
        case Instruction::SDiv:
        case Instruction::UDiv:
        case Instruction::FDiv: {
            result = Domain::div(left_domain, right_domain);
            break;
        }
    }
    NOut->erase(variable(binary_operation));
    NOut->insert(pair<string, Domain *>(variable(binary_operation), result));
    outs() << "variable(binary_operation): " << variable(binary_operation) << "\n";
    outs() << "result->Value: " << result->Value << "\n";
}

void handleCastInstruction(CastInst *cast_instruction, const Memory *In, Memory *NOut) {
    Domain *domain = nullptr;
    auto it = In->find(variable(cast_instruction->getOperand(0)));
    domain = (it != In->end()) ? it->second : new Domain(Domain::Uninit);
    NOut->erase(variable(cast_instruction));
    NOut->insert(std::pair<std::string, Domain *>(variable(cast_instruction), domain));
    outs() << "variable(cast_instruction): " << variable(cast_instruction) << "\n";
    outs() << "domain->Value: " << domain->Value << "\n";
}

void handleCompareInstruction(CmpInst *compare_instruction, const Memory *In, Memory *NOut) {
    Domain *result = nullptr;
    Domain *left_domain = nullptr;
    Domain *right_domain = nullptr;
    Value *left_operand = compare_instruction->getOperand(0);

    if (ConstantInt *left_constant = dyn_cast<ConstantInt>(left_operand)) {
        left_domain = new Domain(left_constant->isZero() ? Domain::Zero : Domain::NonZero);
    } else {
        auto it = In->find(variable(left_operand));
        left_domain = (it != In->end()) ? it->second : new Domain(Domain::Uninit);
    }
    Value *right_operand = compare_instruction->getOperand(1);
    if (ConstantInt *right_constant = dyn_cast<ConstantInt>(right_operand)) {
        right_domain = new Domain(right_constant->isZero() ? Domain::Zero : Domain::NonZero);
    } else {
        auto it = In->find(variable(right_operand));
        right_domain = (it != In->end()) ? it->second : new Domain(Domain::Uninit);
    }
    switch (compare_instruction->getPredicate()) {
        case CmpInst::ICMP_EQ: {
            if (left_domain->Value == Domain::Uninit || right_domain->Value == Domain::Uninit) {
                result = new Domain(Domain::Uninit);
            } else if (left_domain->Value == Domain::MaybeZero ||
                       right_domain->Value == Domain::MaybeZero) {
                result = new Domain(Domain::MaybeZero);
            } else if (left_domain->Value == Domain::Zero && right_domain->Value == Domain::Zero) {
                result = new Domain(Domain::NonZero);
            } else if (left_domain->Value == Domain::NonZero &&
                       right_domain->Value == Domain::NonZero) {
                result = new Domain(Domain::MaybeZero);
            } else {
                result = new Domain(Domain::Zero);
            }
            break;
        }
        case CmpInst::ICMP_ULE:
        case CmpInst::ICMP_SLE:
        case CmpInst::ICMP_UGE:
        case CmpInst::ICMP_SGE: {
            if (left_domain->Value == Domain::Uninit || right_domain->Value == Domain::Uninit) {
                result = new Domain(Domain::Uninit);
            } else if (left_domain->Value == Domain::Zero && right_domain->Value == Domain::Zero) {
                result = new Domain(Domain::NonZero);
            } else {
                result = new Domain(Domain::MaybeZero);
            }
            break;
        }
        case CmpInst::ICMP_ULT:
        case CmpInst::ICMP_SLT:
        case CmpInst::ICMP_UGT:
        case CmpInst::ICMP_SGT: {
            if (left_domain->Value == Domain::Uninit || right_domain->Value == Domain::Uninit) {
                result = new Domain(Domain::Uninit);
            } else if (left_domain->Value == Domain::Zero && right_domain->Value == Domain::Zero) {
                result = new Domain(Domain::Zero);
            } else {
                result = new Domain(Domain::MaybeZero);
            }
            break;
        }
        case CmpInst::ICMP_NE: {
            if (left_domain->Value == Domain::Uninit || right_domain->Value == Domain::Uninit) {
                result = new Domain(Domain::Uninit);
            } else if (left_domain->Value == Domain::MaybeZero ||
                       right_domain->Value == Domain::MaybeZero) {
                result = new Domain(Domain::MaybeZero);
            } else if (left_domain->Value == Domain::Zero && right_domain->Value == Domain::Zero) {
                result = new Domain(Domain::Zero);
            } else if (left_domain->Value == Domain::NonZero &&
                       right_domain->Value == Domain::NonZero) {
                result = new Domain(Domain::MaybeZero);
            } else {
                result = new Domain(Domain::NonZero);
            }
            break;
        }
    }
    NOut->erase(variable(compare_instruction));
    NOut->insert(pair<string, Domain *>(variable(compare_instruction), result));
    outs() << "variable(compare_instruction): " << variable(compare_instruction) << "\n";
    outs() << "result->Value: " << result->Value << "\n";
}

void handleBranchInstruction(BranchInst *branch_instruction, const Memory *In, Memory *NOut) {
    //branch_instruction->getCondition()
    // NOut->erase(variable(branch_instruction));
    // NOut->insert(pair<string, Domain *>(variable(branch_instruction), new
    // Domain(Domain::MaybeZero)));
}

void handleInputVar(Instruction *I, const Memory *In, Memory *NOut) {
    NOut->erase(variable(I));
    NOut->insert(pair<string, Domain *>(variable(I), new Domain(Domain::MaybeZero)));
}

void *handlePhiNode(PHINode *phi_node, const Memory *In, Memory *NOut) {
    Value *cv = phi_node->hasConstantValue();
    if (cv) {
        ConstantInt *constant = dyn_cast<ConstantInt>(cv);
        //Mem->erase(variable(cast_instruction));
        //Mem->insert(std::pair<std::string, Domain *>(variable(cast_instruction), domain));
        return new Domain(constant->isZero() ? Domain::Zero : Domain::NonZero);
    }
    unsigned int n = phi_node->getNumIncomingValues();
    Domain *joined = NULL;
    for (unsigned int i = 0; i < n; i++) {
        Domain *V = phi_node->getIncomingValue(i); // recursion
        if (!joined) {
            joined = V;
        }
        joined = Domain::join(joined, V);
    }
    return joined;
}

void DivZeroAnalysis::transfer(Instruction *I, const Memory *In, Memory *NOut) {
    if (BinaryOperator *binary_operation = dyn_cast<BinaryOperator>(I)) {
        outs() << "binary_operation" << "\n";
        outs() << variable(binary_operation) << "\n";
        handleBinaryOperator(binary_operation, In, NOut);
    } else if (CastInst *cast_instruction = dyn_cast<CastInst>(I)) {
        outs() << "cast_instruction" << "\n";
        outs() << variable(cast_instruction) << "\n";
        handleCastInstruction(cast_instruction, In, NOut);
    } else if (CmpInst *compare_instruction = dyn_cast<CmpInst>(I)) {
        outs() << "compare_instruction" << "\n";
        outs() << variable(compare_instruction) << "\n";
        handleCompareInstruction(compare_instruction, In, NOut);
    } else if (BranchInst *branch_instruction = dyn_cast<BranchInst>(I)) {
        outs() << "branch_instruction" << "\n";
        handleBranchInstruction(branch_instruction, In, NOut);
    } else if (isInput(I)) {
        outs() << "isInput" << "\n";
        handleInputVar(I, In, NOut);
    } else if (PHINode *phi_instruction = dyn_cast<PHINode>(I)) {
        outs() << "phi_instruction" << "\n";
        handlePhiNode(I, In, NOut);
    }
}

void DivZeroAnalysis::flowOut(Instruction *I, Memory *Pre, Memory *Post,
                              SetVector<Instruction *> &WorkSet) {
    if (!equal(Pre, Post)) {
        OutMap[I] = join(InMap[I], Post);
        WorkSet.insert(I);
    }
}

void DivZeroAnalysis::doAnalysis(Function &F) {
    SetVector<Instruction *> WorkSet;
    for (inst_iterator I = inst_begin(F), E = inst_end(F); I != E; ++I) {
        WorkSet.insert(&(*I));
    }
    while (!WorkSet.empty()) {
        outs() << "\n## New iteration ## " << WorkSet.size() << "\n";
        Instruction *instruction = WorkSet.front();
        WorkSet.remove(instruction);
        outs() << "Instruction: " << variable(instruction) << "\n";
        Memory *Nout = new Memory();
        Nout = join(Nout, OutMap[instruction]);
        flowIn(instruction, InMap[instruction]);
        outs() << "IN:" << "\n";
        for (auto m : *InMap[instruction]) {
            outs() << "[" << m.first << ", " << m.second->Value << "] " << "\n";
        }
        transfer(instruction, InMap[instruction], Nout);
        flowOut(instruction, OutMap[instruction], Nout, WorkSet);
        outs() << "OUT:" << "\n";
        for (auto m : *OutMap[instruction]) {
            outs() << "[" << m.first << ", " << m.second->Value << "] " << "\n";
        }
        outs() << "\n";
    }
}

bool DivZeroAnalysis::check(Instruction *I) {
    if (BinaryOperator *binary_operation = dyn_cast<BinaryOperator>(I)) {
        if ((binary_operation->getOpcode() == Instruction::SDiv) ||
            (binary_operation->getOpcode() == Instruction::UDiv) ||
            (binary_operation->getOpcode() == Instruction::FDiv)) {
            Domain *denominator_domain = new Domain(Domain::Uninit);
            if (ConstantInt *constant = dyn_cast<ConstantInt>(binary_operation->getOperand(1))) {
                denominator_domain =
                    new Domain(constant->isZero() ? Domain::Zero : Domain::NonZero);
            } else {
                auto mapPtr = InMap[binary_operation];
                auto it = mapPtr->find(variable(binary_operation->getOperand(1)));
                if (it != mapPtr->end()) {
                    denominator_domain = it->second;
                } else {
                    outs() << "ERROR! Neither contant nor variable no found!" << "\n";
                }
            }
            if (denominator_domain->Value == Domain::Zero ||
                denominator_domain->Value == Domain::MaybeZero) {
                return true;
            }
        }
    }
    return false;
}

char DivZeroAnalysis::ID = 1;
static RegisterPass<DivZeroAnalysis> X("DivZero", "Divide-by-zero Analysis", false, false);
} // namespace dataflow
