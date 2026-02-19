#ifndef ANALYSIS_ENGINE_H
#define ANALYSIS_ENGINE_H

#include <vector>

#include "database.h"
#include "models.h"

std::vector<TaxResult> analyze_households(const std::vector<Household>& households, Database& db,
                                          int run_id);

#endif
