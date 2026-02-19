#include "analysis_engine.h"

#include <algorithm>
#include <cmath>
#include <stdexcept>
#include <unordered_map>

namespace {

constexpr double kEwmaAlpha = 0.6;
constexpr double kStandardDeduction = 10000.0;

struct Lot {
  int lot_id;
  int purchase_order;
  std::string asset_id;
  std::string date;
  double qty_remaining;
  double buy_price;
};

double round2(double v) { return std::round(v * 100.0) / 100.0; }

long long round_avalon_dollar(double v) { return static_cast<long long>(std::llround(v)); }

bool lot_order_less(const Lot& a, const Lot& b) {
  if (a.asset_id != b.asset_id) {
    return a.asset_id < b.asset_id;
  }
  if (a.date != b.date) {
    return a.date < b.date;
  }
  return a.purchase_order < b.purchase_order;
}

double sum_vec(const std::vector<double>& vals) {
  double s = 0.0;
  for (double v : vals) s += v;
  return s;
}

double compute_ewma(const std::vector<double>& prior, double current_gross) {
  if (prior.empty()) {
    return current_gross;
  }
  double ewma = prior[0];
  for (size_t i = 1; i < prior.size(); ++i) {
    ewma = kEwmaAlpha * prior[i] + (1.0 - kEwmaAlpha) * ewma;
  }
  ewma = kEwmaAlpha * current_gross + (1.0 - kEwmaAlpha) * ewma;
  return ewma;
}

// Assumption: child deduction is percent of gross income, capped at 10% at 10+ children.
double compute_child_deduction(double gross_income, int num_children) {
  const int capped = std::max(0, std::min(10, num_children));
  const double rate = static_cast<double>(capped) / 100.0;
  return gross_income * rate;
}

double compute_federal_bracket_tax(double taxable_income) {
  double tax = 0.0;
  double remaining = taxable_income;

  const double tier1 = std::min(remaining, 100000.0);
  tax += tier1 * 0.05;
  remaining -= tier1;

  if (remaining > 0.0) {
    const double tier2 = std::min(remaining, 100000.0);
    tax += tier2 * 0.10;
    remaining -= tier2;
  }

  if (remaining > 0.0) {
    const double tier3 = std::min(remaining, 100000.0);
    tax += tier3 * 0.15;
    remaining -= tier3;
  }

  if (remaining > 0.0) {
    tax += remaining * 0.20;
  }

  return tax;
}

double compute_texas_tax(double taxable_income) {
  double tax = 0.0;
  double remaining = taxable_income;

  const double tier1 = std::min(remaining, 90000.0);
  tax += tier1 * 0.03;
  remaining -= tier1;

  if (remaining > 0.0) {
    const double tier2 = std::min(remaining, 110000.0);
    tax += tier2 * 0.05;
    remaining -= tier2;
  }

  if (remaining > 0.0) {
    tax += remaining * 0.07;
  }

  return tax;
}

}  // namespace

std::vector<TaxResult> analyze_households(const std::vector<Household>& households, Database& db,
                                          int run_id) {
  std::vector<TaxResult> results;
  results.reserve(households.size());

  for (const auto& h : households) {
    std::unordered_map<std::string, std::vector<Lot>> lots_by_asset;

    int next_lot_id = 1;
    for (size_t i = 0; i < h.purchases.size(); ++i) {
      const auto& p = h.purchases[i];
      Lot lot{next_lot_id++, static_cast<int>(i), p.asset_id, p.date, p.quantity, p.unit_price};
      lots_by_asset[p.asset_id].push_back(lot);

      db.insert_capital_lot(run_id, h.taxpayer_id, lot.lot_id, lot.purchase_order, p.asset_id,
                            p.quantity, p.quantity, p.unit_price, p.date);
    }

    for (auto& kv : lots_by_asset) {
      std::sort(kv.second.begin(), kv.second.end(), lot_order_less);
    }

    long long net_cap_gain_rounded = 0;
    for (size_t sale_idx = 0; sale_idx < h.sales.size(); ++sale_idx) {
      const auto& s = h.sales[sale_idx];
      double remaining = s.quantity;
      auto it = lots_by_asset.find(s.asset_id);
      if (it == lots_by_asset.end()) {
        continue;
      }

      auto& lots = it->second;
      for (auto& lot : lots) {
        if (remaining <= 1e-9) {
          break;
        }
        if (lot.qty_remaining <= 1e-9) {
          continue;
        }

        const double matched = std::min(remaining, lot.qty_remaining);
        const double realized = matched * (s.unit_price - lot.buy_price);
        const long long realized_rounded = round_avalon_dollar(realized);
        net_cap_gain_rounded += realized_rounded;

        lot.qty_remaining -= matched;
        remaining -= matched;

        db.update_capital_lot_remaining(run_id, h.taxpayer_id, lot.lot_id, lot.qty_remaining);
        db.insert_capital_match(run_id, h.taxpayer_id, static_cast<int>(sale_idx), lot.lot_id,
                                s.asset_id, matched, lot.buy_price, s.unit_price,
                                realized_rounded, s.date);
      }
    }

    const double net_cap_gain = static_cast<double>(net_cap_gain_rounded);
    const double gross_income = h.w2_income + net_cap_gain;

    const double charitable_deduction = sum_vec(h.charitable_donations);
    const double child_deduction = compute_child_deduction(gross_income, h.num_children);
    const double itemized_deduction = charitable_deduction + child_deduction;
    const double chosen_deduction = std::max(kStandardDeduction, itemized_deduction);
    const double taxable_income = std::max(0.0, gross_income - chosen_deduction);

    const double ewma = compute_ewma(h.prior_five_years_income, gross_income);
    const bool federal_surcharge_applies = ewma > 1000000.0;
    const double federal_surcharge = federal_surcharge_applies ? 0.02 * gross_income : 0.0;

    const double federal_bracket_tax = compute_federal_bracket_tax(taxable_income);
    const double federal_tax = federal_bracket_tax + federal_surcharge;

    double state_tax = 0.0;
    if (h.state == "California") {
      state_tax = 0.04 * h.w2_income + 0.06 * std::max(0.0, net_cap_gain);
      if (federal_surcharge_applies) {
        state_tax *= 1.05;
      }
    } else if (h.state == "Texas") {
      state_tax = compute_texas_tax(taxable_income);
      if (chosen_deduction > 15000.0) {
        state_tax *= 0.99;
      }
    } else {
      throw std::runtime_error("unsupported state: " + h.state);
    }

    const double total_tax = federal_tax + state_tax;

    const double federal_tax_out = round2(federal_tax);
    const double state_tax_out = round2(state_tax);

    db.insert_tax_intermediate(run_id, h.taxpayer_id, net_cap_gain, gross_income, ewma,
                               federal_surcharge_applies ? 1 : 0, federal_surcharge,
                               charitable_deduction, child_deduction, itemized_deduction,
                               kStandardDeduction, chosen_deduction, taxable_income,
                               federal_bracket_tax, federal_tax, state_tax, total_tax);

    db.insert_tax_output(run_id, h.input_order, h.taxpayer_id, federal_tax_out, state_tax_out);

    results.push_back(TaxResult{h.taxpayer_id, federal_tax_out, state_tax_out});
  }

  return results;
}
