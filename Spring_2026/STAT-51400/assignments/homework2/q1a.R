### Homework 2 - Question 1(a)
### Fit the three model parameterizations for one-way ANOVA

# Table 3.1 values (slide 7anovaCRD.pdf)
n <- 5
totals <- c(`160` = 2756, `180` = 2937, `200` = 3127, `220` = 3535)
means <- totals / n

# 1) Means model: y_ij = mu_i + epsilon_ij
# Coefficients are the group means.
coef_means <- means

# 2) Effects model: y_ij = mu + tau_i + epsilon_ij, with sum(tau_i) = 0
mu <- mean(means)
tau <- means - mu

# 3) Dummy regression with baseline 160:
# y = beta0 + beta1*x180 + beta2*x200 + beta3*x220 + e
coef_reg <- c(
  `(Intercept)` = as.numeric(means["160"]),
  `x180` = as.numeric(means["180"] - means["160"]),
  `x200` = as.numeric(means["200"] - means["160"]),
  `x220` = as.numeric(means["220"] - means["160"])
)

cat("Model 1 (Means model):   EtchRate_ij = mu_i + e_ij\n")
cat("Model 2 (Effects model): EtchRate_ij = mu + tau_i + e_ij, with sum(tau_i)=0\n")
cat("Model 3 (Regression):    EtchRate = beta0 + beta1*x180 + beta2*x200 + beta3*x220 + e\n\n")

cat("=== Means model coefficients (group means) ===\n")
print(round(coef_means, 4))

cat("\n=== Effects model coefficients ===\n")
cat(sprintf("mu = %.4f\n", mu))
print(round(tau, 4))
cat(sprintf("sum(tau_i) = %.4f\n", sum(tau)))

cat("\n=== Regression model coefficients ===\n")
print(round(coef_reg, 4))
