### Homework 3 - Question 1(b)
### Fisher's LSD pairwise comparisons among brochure designs (manual RCBD)

# Rows = designs (treatments), columns = regions (blocks)
y <- matrix(
  c(
    250, 350, 219, 375,  # Design 1
    400, 525, 390, 580,  # Design 2
    275, 340, 200, 310   # Design 3
  ),
  nrow = 3,
  byrow = TRUE
)
rownames(y) <- c("1", "2", "3")
colnames(y) <- c("NE", "NW", "SE", "SW")

a <- nrow(y)
b <- ncol(y)
N <- a * b
treatment_means <- rowMeans(y)
block_means <- colMeans(y)
grand_mean <- mean(y)

# Manual RCBD ANOVA quantities used by LSD (mean-based formulas)
SS_total <- sum((y - grand_mean)^2)
SS_treatment <- b * sum((treatment_means - grand_mean)^2)
SS_block <- a * sum((block_means - grand_mean)^2)
SS_error <- SS_total - SS_treatment - SS_block
dfE <- (a - 1) * (b - 1)
MSE <- SS_error / dfE
cat(sprintf("MSE = %.2f\n", MSE))

# Fisher's LSD for equal replication (r = number of blocks)
r <- b
alpha <- 0.05
tcrit <- qt(1 - alpha / 2, df = dfE)
cat(sprintf("t_critical = %.2f\n", tcrit))
cat(sprintf("r = %.2f\n", r))

LSD <- tcrit * sqrt(2 * MSE / r)
cat(sprintf("LSD = %.2f\n", LSD))
means <- treatment_means
cat(sprintf("means = %.2f\n", means))

cat("=== Question 1(b): Fisher LSD comparisons ===\n")
cat(sprintf("MSE = %.6f, dfE = %d, t_(alpha/2,dfE) = %.6f\n", MSE, dfE, tcrit))
cat(sprintf("LSD (alpha = %.2f) = %.6f\n\n", alpha, LSD))

# Manual pairwise comparisons (no loop)
diff_12 <- abs(means["1"] - means["2"])
sig_12 <- ifelse(diff_12 > LSD, "DIFFERENT", "NOT different")
cat(sprintf("Design 1 vs 2: |mean diff| = %.4f -> %s\n", diff_12, sig_12))

diff_13 <- abs(means["1"] - means["3"])
sig_13 <- ifelse(diff_13 > LSD, "DIFFERENT", "NOT different")
cat(sprintf("Design 1 vs 3: |mean diff| = %.4f -> %s\n", diff_13, sig_13))

diff_23 <- abs(means["2"] - means["3"])
sig_23 <- ifelse(diff_23 > LSD, "DIFFERENT", "NOT different")
cat(sprintf("Design 2 vs 3: |mean diff| = %.4f -> %s\n", diff_23, sig_23))

cat("\nDesign means:\n")
print(round(means, 4))
