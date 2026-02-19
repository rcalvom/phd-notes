#include "database.h"

#include <stdexcept>

namespace {

void bind_text(sqlite3_stmt* stmt, int idx, const std::string& s) {
  if (sqlite3_bind_text(stmt, idx, s.c_str(), -1, SQLITE_TRANSIENT) != SQLITE_OK) {
    throw std::runtime_error("sqlite bind text failed");
  }
}

void bind_double(sqlite3_stmt* stmt, int idx, double v) {
  if (sqlite3_bind_double(stmt, idx, v) != SQLITE_OK) {
    throw std::runtime_error("sqlite bind double failed");
  }
}

void bind_int(sqlite3_stmt* stmt, int idx, int v) {
  if (sqlite3_bind_int(stmt, idx, v) != SQLITE_OK) {
    throw std::runtime_error("sqlite bind int failed");
  }
}

void bind_int64(sqlite3_stmt* stmt, int idx, long long v) {
  if (sqlite3_bind_int64(stmt, idx, v) != SQLITE_OK) {
    throw std::runtime_error("sqlite bind int64 failed");
  }
}

void step_done(sqlite3_stmt* stmt) {
  if (sqlite3_step(stmt) != SQLITE_DONE) {
    throw std::runtime_error("sqlite step failed");
  }
}

}  // namespace

Database::Database(const std::string& db_path) : db_(nullptr) {
  if (sqlite3_open(db_path.c_str(), &db_) != SQLITE_OK) {
    throw std::runtime_error("failed to open sqlite db");
  }
  exec("PRAGMA journal_mode=WAL;");
  exec("PRAGMA synchronous=NORMAL;");
  create_schema();
}

Database::~Database() {
  if (db_ != nullptr) {
    sqlite3_close(db_);
  }
}

void Database::exec(const std::string& sql) {
  char* err = nullptr;
  if (sqlite3_exec(db_, sql.c_str(), nullptr, nullptr, &err) != SQLITE_OK) {
    std::string msg = (err != nullptr) ? err : "sqlite exec error";
    sqlite3_free(err);
    throw std::runtime_error(msg);
  }
}

void Database::create_schema() {
  exec(
      "CREATE TABLE IF NOT EXISTS runs("
      "run_id INTEGER PRIMARY KEY AUTOINCREMENT,"
      "started_at TEXT DEFAULT CURRENT_TIMESTAMP,"
      "input_file TEXT NOT NULL,"
      "output_file TEXT NOT NULL,"
      "status TEXT NOT NULL"
      ");");

  exec(
      "CREATE TABLE IF NOT EXISTS households_raw("
      "run_id INTEGER NOT NULL,"
      "input_order INTEGER NOT NULL,"
      "taxpayer_id TEXT NOT NULL,"
      "state TEXT NOT NULL,"
      "w2_income REAL NOT NULL,"
      "num_children INTEGER NOT NULL,"
      "prior_incomes_json TEXT NOT NULL,"
      "purchases_json TEXT NOT NULL,"
      "sales_json TEXT NOT NULL,"
      "donations_json TEXT NOT NULL"
      ");");

  exec(
      "CREATE TABLE IF NOT EXISTS capital_lots("
      "run_id INTEGER NOT NULL,"
      "taxpayer_id TEXT NOT NULL,"
      "lot_id INTEGER NOT NULL,"
      "purchase_order INTEGER NOT NULL,"
      "asset_id TEXT NOT NULL,"
      "qty_total REAL NOT NULL,"
      "qty_remaining REAL NOT NULL,"
      "buy_price REAL NOT NULL,"
      "purchase_date TEXT NOT NULL"
      ");");

  exec(
      "CREATE TABLE IF NOT EXISTS capital_matches("
      "run_id INTEGER NOT NULL,"
      "taxpayer_id TEXT NOT NULL,"
      "sale_order INTEGER NOT NULL,"
      "lot_id INTEGER NOT NULL,"
      "asset_id TEXT NOT NULL,"
      "qty_matched REAL NOT NULL,"
      "buy_price REAL NOT NULL,"
      "sale_price REAL NOT NULL,"
      "realized_gain_rounded INTEGER NOT NULL,"
      "sale_date TEXT NOT NULL"
      ");");

  exec(
      "CREATE TABLE IF NOT EXISTS tax_intermediate("
      "run_id INTEGER NOT NULL,"
      "taxpayer_id TEXT NOT NULL,"
      "net_cap_gain REAL NOT NULL,"
      "gross_income REAL NOT NULL,"
      "ewma_income REAL NOT NULL,"
      "federal_surcharge_applies INTEGER NOT NULL,"
      "federal_surcharge_amt REAL NOT NULL,"
      "charitable_deduction REAL NOT NULL,"
      "child_deduction REAL NOT NULL,"
      "itemized_deduction REAL NOT NULL,"
      "standard_deduction REAL NOT NULL,"
      "chosen_deduction REAL NOT NULL,"
      "taxable_income REAL NOT NULL,"
      "federal_bracket_tax REAL NOT NULL,"
      "federal_tax REAL NOT NULL,"
      "state_tax REAL NOT NULL,"
      "total_tax REAL NOT NULL"
      ");");

  exec(
      "CREATE TABLE IF NOT EXISTS tax_output("
      "run_id INTEGER NOT NULL,"
      "input_order INTEGER NOT NULL,"
      "taxpayer_id TEXT NOT NULL,"
      "federal_tax REAL NOT NULL,"
      "state_tax REAL NOT NULL"
      ");");
}

int Database::begin_run(const std::string& input_file, const std::string& output_file) {
  const char* sql = "INSERT INTO runs(input_file, output_file, status) VALUES(?1, ?2, 'running');";
  sqlite3_stmt* stmt = nullptr;
  if (sqlite3_prepare_v2(db_, sql, -1, &stmt, nullptr) != SQLITE_OK) {
    throw std::runtime_error("failed to prepare begin_run");
  }
  bind_text(stmt, 1, input_file);
  bind_text(stmt, 2, output_file);
  step_done(stmt);
  sqlite3_finalize(stmt);
  return static_cast<int>(sqlite3_last_insert_rowid(db_));
}

void Database::set_run_status(int run_id, const std::string& status) {
  const char* sql = "UPDATE runs SET status = ?1 WHERE run_id = ?2;";
  sqlite3_stmt* stmt = nullptr;
  if (sqlite3_prepare_v2(db_, sql, -1, &stmt, nullptr) != SQLITE_OK) {
    throw std::runtime_error("failed to prepare set_run_status");
  }
  bind_text(stmt, 1, status);
  bind_int(stmt, 2, run_id);
  step_done(stmt);
  sqlite3_finalize(stmt);
}

void Database::insert_household_raw(int run_id, const Household& h, const std::string& prior_json,
                                    const std::string& purchases_json,
                                    const std::string& sales_json,
                                    const std::string& donations_json) {
  const char* sql =
      "INSERT INTO households_raw(run_id, input_order, taxpayer_id, state, w2_income, num_children, "
      "prior_incomes_json, purchases_json, sales_json, donations_json) "
      "VALUES(?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10);";
  sqlite3_stmt* stmt = nullptr;
  if (sqlite3_prepare_v2(db_, sql, -1, &stmt, nullptr) != SQLITE_OK) {
    throw std::runtime_error("failed to prepare insert_household_raw");
  }
  bind_int(stmt, 1, run_id);
  bind_int(stmt, 2, h.input_order);
  bind_text(stmt, 3, h.taxpayer_id);
  bind_text(stmt, 4, h.state);
  bind_double(stmt, 5, h.w2_income);
  bind_int(stmt, 6, h.num_children);
  bind_text(stmt, 7, prior_json);
  bind_text(stmt, 8, purchases_json);
  bind_text(stmt, 9, sales_json);
  bind_text(stmt, 10, donations_json);
  step_done(stmt);
  sqlite3_finalize(stmt);
}

void Database::insert_capital_lot(int run_id, const std::string& taxpayer_id, int lot_id, int purchase_order,
                                  const std::string& asset_id, double qty_total,
                                  double qty_remaining, double buy_price,
                                  const std::string& purchase_date) {
  const char* sql =
      "INSERT INTO capital_lots(run_id, taxpayer_id, lot_id, purchase_order, asset_id, qty_total, "
      "qty_remaining, buy_price, purchase_date) VALUES(?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9);";
  sqlite3_stmt* stmt = nullptr;
  if (sqlite3_prepare_v2(db_, sql, -1, &stmt, nullptr) != SQLITE_OK) {
    throw std::runtime_error("failed to prepare insert_capital_lot");
  }
  bind_int(stmt, 1, run_id);
  bind_text(stmt, 2, taxpayer_id);
  bind_int(stmt, 3, lot_id);
  bind_int(stmt, 4, purchase_order);
  bind_text(stmt, 5, asset_id);
  bind_double(stmt, 6, qty_total);
  bind_double(stmt, 7, qty_remaining);
  bind_double(stmt, 8, buy_price);
  bind_text(stmt, 9, purchase_date);
  step_done(stmt);
  sqlite3_finalize(stmt);
}

void Database::update_capital_lot_remaining(int run_id, const std::string& taxpayer_id, int lot_id,
                                            double qty_remaining) {
  const char* sql =
      "UPDATE capital_lots SET qty_remaining = ?1 WHERE run_id = ?2 AND taxpayer_id = ?3 AND lot_id = ?4;";
  sqlite3_stmt* stmt = nullptr;
  if (sqlite3_prepare_v2(db_, sql, -1, &stmt, nullptr) != SQLITE_OK) {
    throw std::runtime_error("failed to prepare update_capital_lot_remaining");
  }
  bind_double(stmt, 1, qty_remaining);
  bind_int(stmt, 2, run_id);
  bind_text(stmt, 3, taxpayer_id);
  bind_int(stmt, 4, lot_id);
  step_done(stmt);
  sqlite3_finalize(stmt);
}

void Database::insert_capital_match(int run_id, const std::string& taxpayer_id, int sale_order, int lot_id,
                                    const std::string& asset_id, double qty_matched,
                                    double buy_price, double sale_price,
                                    long long realized_gain_rounded,
                                    const std::string& sale_date) {
  const char* sql =
      "INSERT INTO capital_matches(run_id, taxpayer_id, sale_order, lot_id, asset_id, qty_matched, "
      "buy_price, sale_price, realized_gain_rounded, sale_date) "
      "VALUES(?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10);";
  sqlite3_stmt* stmt = nullptr;
  if (sqlite3_prepare_v2(db_, sql, -1, &stmt, nullptr) != SQLITE_OK) {
    throw std::runtime_error("failed to prepare insert_capital_match");
  }
  bind_int(stmt, 1, run_id);
  bind_text(stmt, 2, taxpayer_id);
  bind_int(stmt, 3, sale_order);
  bind_int(stmt, 4, lot_id);
  bind_text(stmt, 5, asset_id);
  bind_double(stmt, 6, qty_matched);
  bind_double(stmt, 7, buy_price);
  bind_double(stmt, 8, sale_price);
  bind_int64(stmt, 9, realized_gain_rounded);
  bind_text(stmt, 10, sale_date);
  step_done(stmt);
  sqlite3_finalize(stmt);
}

void Database::insert_tax_intermediate(
    int run_id, const std::string& taxpayer_id, double net_cap_gain, double gross_income,
    double ewma_income, int federal_surcharge_applies, double federal_surcharge_amt,
    double charitable_deduction, double child_deduction, double itemized_deduction,
    double standard_deduction, double chosen_deduction, double taxable_income,
    double federal_bracket_tax, double federal_tax, double state_tax, double total_tax) {
  const char* sql =
      "INSERT INTO tax_intermediate(run_id, taxpayer_id, net_cap_gain, gross_income, ewma_income, "
      "federal_surcharge_applies, federal_surcharge_amt, charitable_deduction, child_deduction, "
      "itemized_deduction, standard_deduction, chosen_deduction, taxable_income, federal_bracket_tax, "
      "federal_tax, state_tax, total_tax) "
      "VALUES(?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15, ?16, ?17);";

  sqlite3_stmt* stmt = nullptr;
  if (sqlite3_prepare_v2(db_, sql, -1, &stmt, nullptr) != SQLITE_OK) {
    throw std::runtime_error("failed to prepare insert_tax_intermediate");
  }

  bind_int(stmt, 1, run_id);
  bind_text(stmt, 2, taxpayer_id);
  bind_double(stmt, 3, net_cap_gain);
  bind_double(stmt, 4, gross_income);
  bind_double(stmt, 5, ewma_income);
  bind_int(stmt, 6, federal_surcharge_applies);
  bind_double(stmt, 7, federal_surcharge_amt);
  bind_double(stmt, 8, charitable_deduction);
  bind_double(stmt, 9, child_deduction);
  bind_double(stmt, 10, itemized_deduction);
  bind_double(stmt, 11, standard_deduction);
  bind_double(stmt, 12, chosen_deduction);
  bind_double(stmt, 13, taxable_income);
  bind_double(stmt, 14, federal_bracket_tax);
  bind_double(stmt, 15, federal_tax);
  bind_double(stmt, 16, state_tax);
  bind_double(stmt, 17, total_tax);

  step_done(stmt);
  sqlite3_finalize(stmt);
}

void Database::insert_tax_output(int run_id, int input_order, const std::string& taxpayer_id,
                                 double federal_tax, double state_tax) {
  const char* sql =
      "INSERT INTO tax_output(run_id, input_order, taxpayer_id, federal_tax, state_tax) "
      "VALUES(?1, ?2, ?3, ?4, ?5);";

  sqlite3_stmt* stmt = nullptr;
  if (sqlite3_prepare_v2(db_, sql, -1, &stmt, nullptr) != SQLITE_OK) {
    throw std::runtime_error("failed to prepare insert_tax_output");
  }

  bind_int(stmt, 1, run_id);
  bind_int(stmt, 2, input_order);
  bind_text(stmt, 3, taxpayer_id);
  bind_double(stmt, 4, federal_tax);
  bind_double(stmt, 5, state_tax);

  step_done(stmt);
  sqlite3_finalize(stmt);
}
