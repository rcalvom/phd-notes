### Homework 2 - Question 4(a)
### Test whether cotton content affects mean tensile strength (alpha = 0.05)

cotton <- factor(rep(c(15, 20, 25, 30, 35), each = 5))
strength <- c(
   7,  7, 15, 11,  9,
  12, 17, 12, 18, 18,
  14, 19, 19, 18, 18,
  19, 25, 22, 19, 23,
   7, 10, 11, 15, 11
)

data <- data.frame(Cotton = cotton, Strength = strength)

# Manual ANOVA calculations
a <- nlevels(data$Cotton)
N <- nrow(data)
n_i <- as.numeric(table(data$Cotton))
means_i <- tapply(data$Strength, data$Cotton, mean)
grand_mean <- mean(data$Strength)


ss_total <- sum((data$Strength - grand_mean)^2)
ss_treat <- sum(n_i * (means_i - grand_mean)^2)
ss_error <- ss_total - ss_treat

df_treat <- a - 1
df_error <- N - a
df_total <- N - 1

ms_treat <- ss_treat / df_treat
ms_error <- ss_error / df_error
f_stat <- ms_treat / ms_error
p_value <- pf(f_stat, df1 = df_treat, df2 = df_error, lower.tail = FALSE)

manual_tbl <- data.frame(
  Source = c("Cotton", "Error", "Total"),
  Df = c(df_treat, df_error, df_total),
  SumSq = c(ss_treat, ss_error, ss_total),
  MeanSq = c(ms_treat, ms_error, NA_real_),
  F = c(f_stat, NA_real_, NA_real_)
)

cat("=== Question 4(a): One-way ANOVA test ===\n")
manual_out <- manual_tbl
manual_out[, c("SumSq", "MeanSq", "F")] <- round(manual_out[, c("SumSq", "MeanSq", "F")], 4)
print(manual_out, row.names = FALSE)
cat("\n")
cat(sprintf("F statistic = %.4f\n", f_stat))
cat(sprintf("p-value = %.6f\n", p_value))

alpha <- 0.05
if (p_value < alpha) {
  cat("Conclusion: Reject H0. Cotton content significantly affects mean tensile strength.\n")
} else {
  cat("Conclusion: Fail to reject H0. No significant effect of cotton content on mean tensile strength.\n")
}

cat("\n=== Software check (anova(lm)) ===\n")
fit <- lm(Strength ~ Cotton, data = data)
print(anova(fit))
