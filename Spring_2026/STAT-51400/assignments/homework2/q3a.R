### Homework 2 - Question 3(a)
### Test H0: all mixing-technique means are equal (alpha = 0.05)

technique <- factor(rep(1:4, each = 4))
strength <- c(
  3129, 3000, 2865, 2890,
  3200, 3300, 2975, 3150,
  2800, 2900, 2985, 3050,
  2600, 2700, 2600, 2765
)

data <- data.frame(Technique = technique, Strength = strength)

# Manual one-way ANOVA calculations (no anova() call)
a <- nlevels(data$Technique)
N <- nrow(data)
n_i <- as.numeric(table(data$Technique))
means_i <- tapply(data$Strength, data$Technique, mean)
grand_mean <- mean(data$Strength)

ss_treat <- sum(n_i * (means_i - grand_mean)^2)

ss_total <- sum((data$Strength - grand_mean)^2)
ss_error <- ss_total - ss_treat


df_treat <- a - 1
df_error <- N - a


ms_treat <- ss_treat / df_treat
ms_error <- ss_error / df_error
f_stat <- ms_treat / ms_error

p_value <- pf(f_stat, df1 = df_treat, df2 = df_error, lower.tail = FALSE)

cat("=== Question 3(a): ANOVA hypothesis test ===\n")
anova_manual <- data.frame(
  Source = c("Technique", "Error", "Total"),
  Df = c(df_treat, df_error, N - 1),
  SumSq = c(ss_treat, ss_error, ss_total),
  MeanSq = c(ms_treat, ms_error, NA_real_),
  F = c(f_stat, NA_real_, NA_real_)
)
out <- anova_manual
out[, c("SumSq", "MeanSq", "F")] <- round(out[, c("SumSq", "MeanSq", "F")], 4)
print(out, row.names = FALSE)
cat("\n")
cat(sprintf("F statistic = %.4f\n", f_stat))
cat(sprintf("p-value = %.6f\n", p_value))

alpha <- 0.05
if (p_value < alpha) {
  cat("Conclusion: Reject H0. Mixing techniques significantly affect tensile strength.\n")
} else {
  cat("Conclusion: Fail to reject H0. No significant difference among technique means.\n")
}
