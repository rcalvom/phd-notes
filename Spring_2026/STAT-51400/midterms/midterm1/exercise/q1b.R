# STAT 514 - Midterm 1 - Question 1(b)
# Fill ANOVA table for one-way ANOVA (Diet A, B, C)

# Data
A <- c(62, 60, 63, 60, 61)
B <- c(63, 67, 71, 70, 68)
C <- c(68, 66, 67, 65, 69)

y <- c(A, B, C)
diet <- factor(rep(c("A", "B", "C"), each = 5))

# Basic counts
a <- nlevels(diet)           # number of treatments
N <- length(y)               # total sample size
n_i <- as.numeric(table(diet))

# Means
ybar <- mean(y)
ybar_i <- tapply(y, diet, mean)

# Sums of squares
# Total corrected SS: sum((y_ij - ybar)^2)
SS_total <- sum((y - ybar)^2)

# Regression/Treatment SS: sum(n_i * (ybar_i - ybar)^2)
SS_reg <- sum(n_i * (ybar_i - ybar)^2)

# Error SS: SS_total - SS_reg
SS_error <- SS_total - SS_reg

# Degrees of freedom
df_reg <- a - 1
df_error <- N - a
df_total <- N - 1

# Mean squares and F
MS_reg <- SS_reg / df_reg
MS_error <- SS_error / df_error
F_stat <- MS_reg / MS_error

anova_tbl <- data.frame(
  Source = c("Regression", "Error", "Total"),
  df = c(df_reg, df_error, df_total),
  SumSq = c(SS_reg, SS_error, SS_total),
  MeanSq = c(MS_reg, MS_error, NA),
  F = c(F_stat, NA, NA)
)

cat("=== Question 1(b): ANOVA table ===\n")
anova_print <- anova_tbl
anova_print[, c("SumSq", "MeanSq", "F")] <- round(anova_print[, c("SumSq", "MeanSq", "F")], 4)
print(anova_print, row.names = FALSE)

# Given in exam statement: SSE = 55.60
cat(sprintf("\nCheck SSE (exam gives 55.60): %.2f\n", SS_error))

# Optional verification with lm
aov_fit <- lm(y ~ diet)
cat("\nVerification with anova(lm(y ~ diet)):\n")
print(anova(aov_fit))
