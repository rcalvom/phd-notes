#include "Strategy.h"


void searchStrategy(z3::expr_vector &OldVec) {
    if (OldVec.size() == 0) {
        return;
    }

    std::cout << "Current vector" << std::endl;
    for (auto expr : OldVec) {
        std::cout << expr.to_string() << std::endl;
    }

    z3::expr last = !OldVec.back();
    OldVec.pop_back();
    OldVec.push_back(last);

    std::cout << "Next vector" << std::endl;
    for (auto expr : OldVec) {
        std::cout << expr.to_string() << std::endl;
    }
}