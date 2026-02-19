#include <iostream>
#include <stdexcept>
#include <string>

#include "analysis_engine.h"
#include "database.h"
#include "ndjson_parser.h"
#include "output_writer.h"

namespace {

struct Args {
  std::string input_file;
  std::string output_file;
  std::string db_file = "tax_debug.sqlite3";
};

Args parse_args(int argc, char** argv) {
  Args args;
  for (int i = 1; i < argc; ++i) {
    const std::string cur(argv[i]);
    auto next_value = [&](const std::string& flag) -> std::string {
      if (i + 1 >= argc) {
        throw std::runtime_error("missing value for " + flag);
      }
      return argv[++i];
    };

    if (cur == "--inputFile" || cur == "--input") {
      args.input_file = next_value(cur);
    } else if (cur == "--outputFile" || cur == "--output") {
      args.output_file = next_value(cur);
    } else if (cur == "--dbFile") {
      args.db_file = next_value(cur);
    } else if (cur == "--help" || cur == "-h") {
      std::cout << "Usage: taxcalc --inputFile INPUT --outputFile OUTPUT [--dbFile DB]\n"
                << "Also supports: --input INPUT --output OUTPUT\n";
      std::exit(0);
    } else {
      throw std::runtime_error("unknown arg: " + cur);
    }
  }

  if (args.input_file.empty() || args.output_file.empty()) {
    throw std::runtime_error("--inputFile/--outputFile (or --input/--output) are required");
  }
  return args;
}

}  // namespace

int main(int argc, char** argv) {
  try {
    const Args args = parse_args(argc, argv);

    Database db(args.db_file);
    const int run_id = db.begin_run(args.input_file, args.output_file);

    try {
      const auto households = parse_households(args.input_file, db, run_id);
      const auto results = analyze_households(households, db, run_id);
      write_output_ndjson(args.output_file, results);
      db.set_run_status(run_id, "completed");
    } catch (...) {
      db.set_run_status(run_id, "failed");
      throw;
    }

    return 0;
  } catch (const std::exception& e) {
    std::cerr << "ERROR: " << e.what() << '\n';
    return 1;
  }
}
