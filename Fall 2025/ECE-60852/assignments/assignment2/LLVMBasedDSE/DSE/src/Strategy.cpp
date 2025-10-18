#include "Strategy.h"

void searchStrategy(z3::expr_vector &OldVec) {
    std::cout << "DEBUGGING searchStrategy" << std::endl;
    for (unsigned i = 0; i < OldVec.size(); i++) {
        std::cout << OldVec[i].to_string() << std::endl;
    }

    if (OldVec.size() == 0) {
        return;
    }

    z3::expr Z = OldVec.back();
    OldVec.pop_back();
    OldVec.push_back(!Z);

    for (unsigned i = 0; i < OldVec.size(); i++) {
        std::cout << OldVec[i].to_string() << std::endl;
    }
}
