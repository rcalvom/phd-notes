#ifndef DATABASE_H
#define DATABASE_H

#include <sqlite3.h>

#include <string>

#include "models.h"

class Database {
 public:
  explicit Database(const std::string& db_path);
  ~Database();

  Database(const Database&) = delete;
  Database& operator=(const Database&) = delete;

  int begin_run(const std::string& input_file, const std::string& output_file);
  void set_run_status(int run_id, const std::string& status);

  void insert_household_raw(int run_id, const Household& h, const std::string& prior_json,
                            const std::string& purchases_json, const std::string& sales_json,
                            const std::string& donations_json);

  void insert_capital_lot(int run_id, const std::string& taxpayer_id, int lot_id, int purchase_order,
                          const std::string& asset_id, double qty_total, double qty_remaining,
                          double buy_price, const std::string& purchase_date);

  void update_capital_lot_remaining(int run_id, const std::string& taxpayer_id, int lot_id,
                                    double qty_remaining);

  void insert_capital_match(int run_id, const std::string& taxpayer_id, int sale_order, int lot_id,
                            const std::string& asset_id, double qty_matched, double buy_price,
                            double sale_price, long long realized_gain_rounded,
                            const std::string& sale_date);

  void insert_tax_intermediate(
      int run_id, const std::string& taxpayer_id, double net_cap_gain, double gross_income,
      double ewma_income, int federal_surcharge_applies, double federal_surcharge_amt,
      double charitable_deduction, double child_deduction, double itemized_deduction,
      double standard_deduction, double chosen_deduction, double taxable_income,
      double federal_bracket_tax, double federal_tax, double state_tax, double total_tax);

  void insert_tax_output(int run_id, int input_order, const std::string& taxpayer_id, double federal_tax,
                         double state_tax);

  sqlite3* handle() const { return db_; }

 private:
  sqlite3* db_;

  void exec(const std::string& sql);
  void create_schema();
};

#endif
