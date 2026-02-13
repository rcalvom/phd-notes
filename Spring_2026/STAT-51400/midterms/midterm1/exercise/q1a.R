# STAT 514 - Midterm 1 - Question 1(a)
# Estimate treatment-effect model parameters in R

# Data
A <- c(62, 60, 63, 60, 61)
B <- c(63, 67, 71, 70, 68)
C <- c(68, 66, 67, 65, 69)

y <- c(A, B, C)
diet <- factor(rep(c("A", "B", "C"), each = 5))

# Basic summaries
N <- length(y)
T_total <- sum(y)
grand_mean <- mean(y)  # mu-hat in treatment-effects model
means <- tapply(y, diet, mean)

# Treatment-effects parameterization:
# y_ij = mu + tau_i + e_ij, with constraint sum_i tau_i = 0
mu_hat <- grand_mean
tau_hat <- means - mu_hat

cat("=== Question 1(a): Treatment-effects estimates ===\n")
cat(sprintf("N = %d, Total sum = %.0f\n", N, T_total))
cat(sprintf("mu_hat (grand mean) = %.6f\n", mu_hat))
cat("tau_hat values (sum-to-zero coding):\n")
print(round(tau_hat, 6))
cat(sprintf("Check sum(tau_hat) = %.6f\n\n", sum(tau_hat)))

# Optional: equivalent cell means (mu_i = mu + tau_i)
cat("Cell means (mu_i = mu + tau_i):\n")
print(round(means, 6))
cat("\n")

# Optional verification with lm()
fit <- lm(y ~ diet)
cat("R default (reference coding, baseline A) coefficients:\n")
print(round(coef(fit), 6))
