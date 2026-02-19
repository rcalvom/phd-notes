#ifndef OUTPUT_WRITER_H
#define OUTPUT_WRITER_H

#include <string>
#include <vector>

#include "models.h"

void write_output_ndjson(const std::string& output_file, const std::vector<TaxResult>& results);

#endif
