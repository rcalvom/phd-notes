# STAT 514 - Midterm 1 - Question 2(a)
# Complete ANOVA table from incomplete lm() summary output

# Given from the screenshot/output
rse <- 0.3975              # residual standard error
r2 <- 0.6323               # multiple R-squared
df_error <- 43             # residual degrees of freedom
p <- 3                     # predictors: theft, fire, income

# Degrees of freedom
n <- df_error + p + 1      # +1 for intercept

df_reg <- p
df_tot <- n - 1

# Mean square error and SSE
mse <- rse^2
sse <- mse * df_error

# Use R^2 = SSR / SST and SSE = (1 - R^2) * SST
sst <- sse / (1 - r2)
ssr <- sst - sse

# Mean square regression and F-statistic
msr <- ssr / df_reg
f_stat <- msr / mse

anova_tbl <- data.frame(
  Source = c("Regression", "Error", "Total"),
  df = c(df_reg, df_error, df_tot),
  SumSq = c(ssr, sse, sst),
  MeanSq = c(msr, mse, NA),
  F = c(f_stat, NA, NA)
)

cat("=== Question 2(a): Completed ANOVA table ===\n")
anova_print <- anova_tbl
anova_print[, c("SumSq", "MeanSq", "F")] <- round(anova_print[, c("SumSq", "MeanSq", "F")], 4)
print(anova_print, row.names = FALSE)

cat("\nChecks:\n")
cat(sprintf("n = %d\n", n))
cat(sprintf("R^2 check = SSR/SST = %.4f\n", ssr/sst))
