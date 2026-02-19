# Specification: The Tax Code

## Background

You live in the country of Avalon. Spring is here and the smell of taxes
fills the air. Like the United States, citizens of Avalon pay taxes both
to their federal government and to the state in which they reside.

Avalon has recently modernized its tax system. There is a new federal
tax code and a new tax code for each state. However, the official tax
calculator is proprietary and not publicly available. You would like to
implement your own tax calculator so that you do not have to compute
your taxes by hand.

Your task is to implement a tax computation engine that reads an input
file describing taxpayers' financial information and outputs the total
tax that each one owes under the 2026 Avalon tax code (federal + state).

------------------------------------------------------------------------

# Avalon Federal Tax Code

## Gross Income

Gross income consists of:

-   **Wage Income (W2)** --- Fully taxable.
-   **Capital Gains and Losses**

Gain formula:

    Gain = Sale Price - Purchase Price

Gross income:

    Gross Income = Wage Income + Net Capital Gain

------------------------------------------------------------------------

## Capital Gains Computation

Realized gain:

    Gain = q * (p_s - p_b)

FIFO (first-in, first-out) must be used for matching sales to purchases.

Net capital gain:

    Net Capital Gain = sum of all realized gains and losses

Transactions are rounded to the nearest Avalon dollar.

------------------------------------------------------------------------

## Deductions

Taxpayers may choose:

### Standard Deduction

-   \$10,000

### Itemized Deductions

-   Charitable Donation Deduction\
-   Child Tax Deduction

Charitable deduction:

    Charitable Deduction = sum(d_i)

Child deduction schedule: 1% first child, increasing up to 10% for the
tenth child.

Taxable income:

    Taxable Income = Gross Income - Allowable Deductions

------------------------------------------------------------------------

## Federal Tax Brackets

  Income Range       Rate
  ------------------ ------
  0--100,000         5%
  100,000--200,000   10%
  200,000--300,000   15%
  \>300,000          20%

------------------------------------------------------------------------

## High-Income Surcharge

EWMA smoothing factor: α = 0.6

If EWMA \> 1,000,000:

    Surcharge = 0.02 * Gross Income

National tax:

    National Tax = Bracket Tax + Surcharge

------------------------------------------------------------------------

# Avalon State Tax Code

## California

    CA Tax =
    0.04 * Wage Income +
    0.06 * max(0, Net Capital Gain)

Additional 5% surcharge if federal surcharge applies.

------------------------------------------------------------------------

## Texas

Applied to Taxable Income:

  Income Range      Rate
  ----------------- ------
  0--90,000         3%
  90,000--200,000   5%
  \>200,000         7%

If federal deductions exceed 15,000, apply 1% reduction to computed
state tax.

------------------------------------------------------------------------

# Total Tax

    Total Tax = National Tax + State Tax

------------------------------------------------------------------------

# Input Format (NDJSON)

Each line is one household JSON object containing:

-   taxpayer_id
-   state
-   w2_income
-   num_children
-   prior_five_years_income (5 numbers)
-   purchases (array)
-   sales (array)
-   charitable_donations (array)

------------------------------------------------------------------------

# Output Format (NDJSON)

Each output line contains:

-   taxpayer_id
-   federal_tax
-   state_tax

Order must match input.

------------------------------------------------------------------------

# CLI

Arguments:

    --inputFile HOUSEHOLDS.NDJSON
    --outputFile TAXES.NDJSON
