### Homework 2 - Question 1(c)
### Two-sample t-test with equal variances (slide 17, 5ComparativeExperiment)

# Use only the two groups being compared.
y160 <- c(575, 542, 530, 539, 570)
y180 <- c(565, 593, 590, 579, 610)

n1 <- length(y160)
n2 <- length(y180)
mean_160 <- mean(y160)
mean_180 <- mean(y180)
s2_160 <- sum((y160 - mean_160)^2) / (n1 - 1)
cat(sprintf("Sum(160) = %.4f\n", sum((y160 - mean_160)^2)))
s2_180 <- sum((y180 - mean_180)^2) / (n2 - 1)
cat(sprintf("Sum(180) = %.4f\n", sum((y180 - mean_180)^2)))

diff_180_160 <- mean_180 - mean_160

# Pooled variance:
# Sp^2 = [ (n1-1)S1^2 + (n2-1)S2^2 ] / (n1+n2-2)
sp2 <- ((n1 - 1) * s2_160 + (n2 - 1) * s2_180) / (n1 + n2 - 2)
se_diff <- sqrt(sp2 * (1 / n1 + 1 / n2))
t_stat <- diff_180_160 / se_diff
df <- n1 + n2 - 2
p_value <- 2 * pt(abs(t_stat), df = df, lower.tail = FALSE)

cat(sprintf("Mean(160) = %.4f\n", mean_160))
cat(sprintf("Mean(180) = %.4f\n", mean_180))
cat(sprintf("S2(160) = %.4f\n", s2_160))
cat(sprintf("S2(180) = %.4f\n", s2_180))
cat(sprintf("Sp2 (pooled variance) = %.4f\n", sp2))
cat(sprintf("Difference (180 - 160) = %.4f\n", diff_180_160))
cat(sprintf("t = %.4f, df = %d, p-value = %.6f\n", t_stat, df, p_value))

alpha <- 0.05
if (p_value < alpha) {
  cat("Conclusion: Yes, etch rates at 160 and 180 are significantly different at alpha = 0.05.\n")
} else {
  cat("Conclusion: No, etch rates at 160 and 180 are not significantly different at alpha = 0.05.\n")
}
