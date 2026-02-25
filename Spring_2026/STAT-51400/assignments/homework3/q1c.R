### Homework 3 - Question 1(c)
### Tukey HSD comparisons among brochure designs (manual RCBD)

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

a <- nrow(y)     # number of designs (treatments)
b <- ncol(y)     # number of blocks
cat(sprintf("b = %.2f\n", b))
N <- a * b
treatment_means <- rowMeans(y)
block_means <- colMeans(y)
grand_mean <- mean(y)

# Manual RCBD ANOVA quantities used by Tukey HSD (mean-based formulas)
SS_total <- sum((y - grand_mean)^2)
SS_treatment <- b * sum((treatment_means - grand_mean)^2)
SS_block <- a * sum((block_means - grand_mean)^2)
SS_error <- SS_total - SS_treatment - SS_block
dfE <- (a - 1) * (b - 1)
MSE <- SS_error / dfE
cat(sprintf("MSE = %.2f\n", MSE))
means <- treatment_means
cat(sprintf("means = %.2f\n", means))

alpha <- 0.05
q_crit <- qtukey(1 - alpha, nmeans = a, df = dfE)
cat(sprintf("q_critical = %.2f\n", q_crit))
HSD <- q_crit * sqrt(MSE / b)
cat(sprintf("HSD = %.2f\n", HSD))

cat("=== Question 1(c): Tukey HSD (design) ===\n")
cat(sprintf("MSE = %.6f, dfE = %d, q_(0.95; k=%d, dfE) = %.6f\n", MSE, dfE, a, q_crit))
cat(sprintf("HSD = %.6f\n\n", HSD))

cat("Pairwise decisions at alpha = 0.05:\n")

# Manual pairwise comparisons (no loop)
diff_21 <- means["2"] - means["1"]
abs_diff_21 <- abs(diff_21)
q_stat_21 <- abs_diff_21 / sqrt(MSE / b)
p_adj_21 <- ptukey(q_stat_21, nmeans = a, df = dfE, lower.tail = FALSE)
sig_21 <- ifelse(abs_diff_21 > HSD, "DIFFERENT", "NOT different")
cat(sprintf(
  "2-1: diff = %.4f, |diff| = %.4f, p-adjusted = %.6f -> %s\n",
  diff_21, abs_diff_21, p_adj_21, sig_21
))

diff_31 <- means["3"] - means["1"]
abs_diff_31 <- abs(diff_31)
q_stat_31 <- abs_diff_31 / sqrt(MSE / b)
p_adj_31 <- ptukey(q_stat_31, nmeans = a, df = dfE, lower.tail = FALSE)
sig_31 <- ifelse(abs_diff_31 > HSD, "DIFFERENT", "NOT different")
cat(sprintf(
  "3-1: diff = %.4f, |diff| = %.4f, p-adjusted = %.6f -> %s\n",
  diff_31, abs_diff_31, p_adj_31, sig_31
))

diff_32 <- means["3"] - means["2"]
abs_diff_32 <- abs(diff_32)
q_stat_32 <- abs_diff_32 / sqrt(MSE / b)
p_adj_32 <- ptukey(q_stat_32, nmeans = a, df = dfE, lower.tail = FALSE)
sig_32 <- ifelse(abs_diff_32 > HSD, "DIFFERENT", "NOT different")
cat(sprintf(
  "3-2: diff = %.4f, |diff| = %.4f, p-adjusted = %.6f -> %s\n",
  diff_32, abs_diff_32, p_adj_32, sig_32
))
