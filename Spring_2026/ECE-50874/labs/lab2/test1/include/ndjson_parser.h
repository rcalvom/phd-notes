#ifndef NDJSON_PARSER_H
#define NDJSON_PARSER_H

#include <string>
#include <vector>

#include "database.h"
#include "models.h"

std::vector<Household> parse_households(const std::string& input_file, Database& db, int run_id);

#endif
