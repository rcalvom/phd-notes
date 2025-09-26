#include "Domain.h"

//===----------------------------------------------------------------------===//
// Abstract Domain Implementation
//===----------------------------------------------------------------------===//

namespace dataflow {

Domain::Domain() { 
    Value = Domain::Element::Uninit; 
}

Domain::Domain(Element value) { Value = value; }

Domain *Domain::add(Domain *domain_left, Domain *domain_right) {
    if (domain_left->Value == Uninit || domain_right->Value == Uninit) {
        return new Domain(MaybeZero);
    }
    if (domain_left->Value == Zero) {
        return new Domain(domain_right->Value);
    }
    if (domain_right->Value == Zero) {
        return new Domain(domain_left->Value);
    }
    return new Domain(MaybeZero);
}

Domain *Domain::sub(Domain *domain_left, Domain *domain_right) {
    if (domain_left->Value == Uninit || domain_right->Value == Uninit) {
        return new Domain(MaybeZero);
    }
    if (domain_left->Value == Zero) {
        return new Domain(domain_right->Value);
    }
    if (domain_right->Value == Zero) {
        return new Domain(domain_left->Value);
    }
    return new Domain(MaybeZero);
}

Domain *Domain::mul(Domain *domain_left, Domain *domain_right) {
    if (domain_left->Value == Uninit || domain_right->Value == Uninit) {
        return new Domain(MaybeZero);
    }
    if (domain_left->Value == Zero || domain_right->Value == Zero) {
        return new Domain(Zero);
    }
    if (domain_left->Value == MaybeZero || domain_right->Value == MaybeZero) {
        return new Domain(MaybeZero);
    }
    return new Domain(NonZero);
}

Domain *Domain::div(Domain *domain_left, Domain *domain_right) {
    if (domain_left->Value == Uninit || domain_right->Value == Uninit) {
        return new Domain(MaybeZero);
    }
    if (domain_right->Value == Zero || domain_right->Value == MaybeZero) {
        return new Domain(MaybeZero);
    }
    return new Domain(domain_left->Value);
}

Domain *Domain::join(Domain *E1, Domain *E2) {
    if (E1->Value == Uninit) {
        return new Domain(*E2);
    }
    if (E2->Value == Uninit) {
        return new Domain(*E1);
    }
    if (E1->Value == E2->Value) {
        return new Domain(E1->Value);
    }
    return new Domain(MaybeZero);
}

static bool order(Domain E1, Domain E2) {
    return false;
}

void Domain::print(raw_ostream &O) { O << Value; }

raw_ostream &operator<<(raw_ostream &O, Domain V) { return O << V.Value; }

} // namespace dataflow
