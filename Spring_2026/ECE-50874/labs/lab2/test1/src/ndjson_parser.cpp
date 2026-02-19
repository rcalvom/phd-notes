#include "ndjson_parser.h"

#include <fstream>
#include <sstream>
#include <stdexcept>

#include "json_utils.h"

namespace {

std::runtime_error parse_error(int line_no, const std::string& msg) {
  std::ostringstream oss;
  oss << "input parse error at line " << line_no << ": " << msg;
  return std::runtime_error(oss.str());
}

double require_double(const Json::Value& obj, const char* key, int line_no) {
  if (!obj.isMember(key) || !obj[key].isNumeric()) {
    throw parse_error(line_no, std::string("missing/invalid numeric field '") + key + "'");
  }
  return obj[key].asDouble();
}

int require_int(const Json::Value& obj, const char* key, int line_no) {
  if (!obj.isMember(key) || !obj[key].isInt()) {
    throw parse_error(line_no, std::string("missing/invalid integer field '") + key + "'");
  }
  return obj[key].asInt();
}

std::string require_string(const Json::Value& obj, const char* key, int line_no) {
  if (!obj.isMember(key) || !obj[key].isString()) {
    throw parse_error(line_no, std::string("missing/invalid string field '") + key + "'");
  }
  return obj[key].asString();
}

std::vector<double> parse_number_array(const Json::Value& arr, const std::string& name, int line_no) {
  if (!arr.isArray()) {
    throw parse_error(line_no, "field '" + name + "' must be an array");
  }
  std::vector<double> out;
  out.reserve(arr.size());
  for (Json::ArrayIndex i = 0; i < arr.size(); ++i) {
    if (!arr[i].isNumeric()) {
      throw parse_error(line_no, "field '" + name + "' must contain only numbers");
    }
    out.push_back(arr[i].asDouble());
  }
  return out;
}

std::vector<Transaction> parse_transactions(const Json::Value& arr, const std::string& name, int line_no) {
  if (!arr.isArray()) {
    throw parse_error(line_no, "field '" + name + "' must be an array");
  }
  std::vector<Transaction> out;
  out.reserve(arr.size());
  for (Json::ArrayIndex i = 0; i < arr.size(); ++i) {
    const Json::Value& row = arr[i];
    if (!row.isObject()) {
      throw parse_error(line_no, "field '" + name + "' must contain objects");
    }
    Transaction t;
    t.asset_id = require_string(row, "asset_id", line_no);
    t.date = require_string(row, "date", line_no);
    t.quantity = require_double(row, "quantity", line_no);
    t.unit_price = require_double(row, "unit_price", line_no);
    out.push_back(t);
  }
  return out;
}

Json::Value to_json_array(const std::vector<double>& vals) {
  Json::Value arr(Json::arrayValue);
  for (double v : vals) {
    arr.append(v);
  }
  return arr;
}

Json::Value to_json_transactions(const std::vector<Transaction>& vals) {
  Json::Value arr(Json::arrayValue);
  for (const auto& t : vals) {
    Json::Value row(Json::objectValue);
    row["asset_id"] = t.asset_id;
    row["date"] = t.date;
    row["quantity"] = t.quantity;
    row["unit_price"] = t.unit_price;
    arr.append(row);
  }
  return arr;
}

}  // namespace

std::vector<Household> parse_households(const std::string& input_file, Database& db, int run_id) {
  std::ifstream in(input_file);
  if (!in.is_open()) {
    throw std::runtime_error("failed to open input file: " + input_file);
  }

  std::vector<Household> out;
  std::string line;
  int line_no = 0;

  while (std::getline(in, line)) {
    ++line_no;
    if (line.empty()) {
      continue;
    }

    Json::Value root;
    std::string err;
    if (!parse_json_line(line, &root, &err)) {
      throw parse_error(line_no, err);
    }
    if (!root.isObject()) {
      throw parse_error(line_no, "line must be a JSON object");
    }

    Household h;
    h.input_order = static_cast<int>(out.size());
    h.taxpayer_id = require_string(root, "taxpayer_id", line_no);
    h.state = require_string(root, "state", line_no);
    h.w2_income = require_double(root, "w2_income", line_no);
    h.num_children = require_int(root, "num_children", line_no);

    if (!root.isMember("prior_five_years_income")) {
      throw parse_error(line_no, "missing field 'prior_five_years_income'");
    }
    h.prior_five_years_income =
        parse_number_array(root["prior_five_years_income"], "prior_five_years_income", line_no);

    if (!root.isMember("purchases")) {
      throw parse_error(line_no, "missing field 'purchases'");
    }
    if (!root.isMember("sales")) {
      throw parse_error(line_no, "missing field 'sales'");
    }
    if (!root.isMember("charitable_donations")) {
      throw parse_error(line_no, "missing field 'charitable_donations'");
    }

    h.purchases = parse_transactions(root["purchases"], "purchases", line_no);
    h.sales = parse_transactions(root["sales"], "sales", line_no);
    h.charitable_donations =
        parse_number_array(root["charitable_donations"], "charitable_donations", line_no);

    db.insert_household_raw(run_id, h, to_compact_json(to_json_array(h.prior_five_years_income)),
                            to_compact_json(to_json_transactions(h.purchases)),
                            to_compact_json(to_json_transactions(h.sales)),
                            to_compact_json(to_json_array(h.charitable_donations)));

    out.push_back(h);
  }

  return out;
}
