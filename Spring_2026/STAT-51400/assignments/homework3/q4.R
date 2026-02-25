### Homework 3 - Question 4
### Latin square analysis for assembly methods (A, B, C, D)

# Data transcribed from SS 4.25
order <- factor(rep(1:4, each = 4))      # rows (order of assembly)
operator <- factor(rep(1:4, times = 4))  # columns (operator)
method <- factor(
  c(
    "C", "D", "A", "B",
    "B", "C", "D", "A",
    "A", "B", "C", "D",
    "D", "A", "B", "C"
  ),
  levels = c("A", "B", "C", "D")
)
y <- c(
  10, 14, 7, 8,
  7, 18, 11, 8,
  5, 10, 11, 9,
  10, 10, 12, 14
)

dat <- data.frame(order = order, operator = operator, method = method, y = y)

# Latin square dimensions
p <- nlevels(method)
N <- length(y)

# Means (for manual SS formulas without correction factor)
grand_mean <- mean(y)
row_means <- tapply(y, order, mean)
column_means <- tapply(y, operator, mean)
treatment_means <- tapply(y, method, mean)

# Sums of squares using the Latin-square partition notation
SS_total <- sum((y - grand_mean)^2)
SS_treatments <- p * sum((treatment_means - grand_mean)^2)
SS_rows <- p * sum((row_means - grand_mean)^2)
SS_columns <- p * sum((column_means - grand_mean)^2)
SS_error <- SS_total - SS_treatments - SS_rows - SS_columns

# Degrees of freedom
df_total <- N - 1
df_rows <- p - 1
df_columns <- p - 1
df_treatments <- p - 1
df_error <- df_total - df_rows - df_columns - df_treatments

# Mean squares
MS_rows <- SS_rows / df_rows
MS_columns <- SS_columns / df_columns
MS_treatments <- SS_treatments / df_treatments
MS_error <- SS_error / df_error

# F tests
F_rows <- MS_rows / MS_error
F_columns <- MS_columns / MS_error
F_treatments <- MS_treatments / MS_error

p_rows <- pf(F_rows, df_rows, df_error, lower.tail = FALSE)
p_columns <- pf(F_columns, df_columns, df_error, lower.tail = FALSE)
p_treatments <- pf(F_treatments, df_treatments, df_error, lower.tail = FALSE)

anova_tab <- data.frame(
  Source = c("Methods (Treatments)", "Order (Rows)", "Operator (Columns)", "Error", "Total"),
  Df = c(df_treatments, df_rows, df_columns, df_error, df_total),
  `Sum Sq` = c(SS_treatments, SS_rows, SS_columns, SS_error, SS_total),
  `Mean Sq` = c(MS_treatments, MS_rows, MS_columns, MS_error, NA),
  `F value` = c(F_treatments, F_rows, F_columns, NA, NA),
  `Pr(>F)` = c(p_treatments, p_rows, p_columns, NA, NA),
  check.names = FALSE
)

cat("=== Question 4: Latin Square ANOVA ===\n\n")
out <- anova_tab
num_cols <- sapply(out, is.numeric)
out[num_cols] <- lapply(out[num_cols], round, 6)
print(out, row.names = FALSE)

cat("\nMethod means:\n")
print(round(tapply(y, method, mean), 4))

alpha <- 0.05
cat("\nConclusions at alpha = 0.05:\n")
cat(ifelse(
  p_treatments < alpha,
  sprintf("- Methods differ significantly (p = %.6f).\n", p_treatments),
  sprintf("- No significant method difference (p = %.6f).\n", p_treatments)
))
cat(ifelse(
  p_rows < alpha,
  sprintf("- Order effect is significant (p = %.6f).\n", p_rows),
  sprintf("- Order effect is not significant (p = %.6f).\n", p_rows)
))
cat(ifelse(
  p_columns < alpha,
  sprintf("- Operator effect is significant (p = %.6f).\n", p_columns),
  sprintf("- Operator effect is not significant (p = %.6f).\n", p_columns)
))

best_method <- names(which.max(tapply(y, method, mean)))
cat(sprintf("- Largest sample mean: Method %s.\n", best_method))
