### Homework 2 - Question 2
### Complete the one-way ANOVA table from the partial output (by hand formulas)

# Given entries from the problem statement
ms_factor_given <- 246.93
ss_error <- 186.53
df_error <- 25
ss_total <- 1174.24
df_total <- 29

# Fill blanks using ANOVA identities
# df_total = df_factor + df_error
# ss_total = ss_factor + ss_error
# ms = ss / df
# F = ms_factor / ms_error
# p-value = P(F_{df_factor, df_error} >= F_obs)

df_factor <- df_total - df_error
ss_factor <- ss_total - ss_error
ms_error <- ss_error / df_error
ms_factor <- ss_factor / df_factor
f_stat <- ms_factor / ms_error
p_value <- pf(f_stat, df1 = df_factor, df2 = df_error, lower.tail = FALSE)

anova_tbl <- data.frame(
  Source = c("Factor", "Error", "Total"),
  DF = c(df_factor, df_error, df_total),
  SS = c(ss_factor, ss_error, ss_total),
  MS = c(ms_factor, ms_error, NA_real_),
  F = c(f_stat, NA_real_, NA_real_),
  P = c(p_value, NA_real_, NA_real_)
)

cat("=== Completed One-way ANOVA table ===\n")
out <- anova_tbl
out$SS <- round(out$SS, 2)
out$MS <- round(out$MS, 4)
out$F <- round(out$F, 4)
out$P <- signif(out$P, 4)
print(out, row.names = FALSE)

cat("\nChecks against given entries:\n")
cat(sprintf("Given MS(Factor) = %.2f\n", ms_factor_given))
cat(sprintf("Computed MS(Factor) = %.4f\n", ms_factor))
cat("(Difference is due to rounding in the provided table.)\n")
