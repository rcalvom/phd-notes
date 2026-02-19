#include "output_writer.h"

#include <fstream>
#include <iomanip>
#include <sstream>
#include <stdexcept>

namespace {

std::string escape_json_string(const std::string& in) {
  std::ostringstream out;
  for (char c : in) {
    if (c == '\\' || c == '\"') {
      out << '\\' << c;
    } else {
      out << c;
    }
  }
  return out.str();
}

}  // namespace

void write_output_ndjson(const std::string& output_file, const std::vector<TaxResult>& results) {
  std::ofstream out(output_file);
  if (!out.is_open()) {
    throw std::runtime_error("failed to open output file: " + output_file);
  }

  for (const auto& r : results) {
    out << "{\"taxpayer_id\":\"" << escape_json_string(r.taxpayer_id)
        << "\",\"federal_tax\":" << std::fixed << std::setprecision(2) << r.federal_tax
        << ",\"state_tax\":" << std::fixed << std::setprecision(2) << r.state_tax << "}\n";
  }
}
