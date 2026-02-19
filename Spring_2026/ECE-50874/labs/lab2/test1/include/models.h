#ifndef MODELS_H
#define MODELS_H

#include <string>
#include <vector>

struct Transaction {
  std::string asset_id;
  std::string date;
  double quantity;
  double unit_price;
};

struct Household {
  int input_order;
  std::string taxpayer_id;
  std::string state;
  double w2_income;
  int num_children;
  std::vector<double> prior_five_years_income;
  std::vector<Transaction> purchases;
  std::vector<Transaction> sales;
  std::vector<double> charitable_donations;
};

struct TaxResult {
  std::string taxpayer_id;
  double federal_tax;
  double state_tax;
};

#endif
