### Homework 2 - Question 4(c)
### Residual analysis and model adequacy comments

cotton <- factor(rep(c(15, 20, 25, 30, 35), each = 5))
strength <- c(
   7,  7, 15, 11,  9,
  12, 17, 12, 18, 18,
  14, 19, 19, 18, 18,
  19, 25, 22, 19, 23,
   7, 10, 11, 15, 11
)

data <- data.frame(Cotton = cotton, Strength = strength)
fit <- lm(Strength ~ Cotton, data = data)
res <- resid(fit)
fitted_vals <- fitted(fit)

# Normal Q-Q plot
png("assignments/homework2/q4c_qqplot.png", width = 900, height = 700)
par(cex.lab = 1.9, cex.axis = 1.7, mar = c(5.2, 5.2, 2.0, 1.2))
qqnorm(
  res,
  main = "",
  xlab = "Theoretical Quantiles",
  ylab = "Sample Quantiles",
  pch = 19,
  col = "steelblue",
  cex = 1.6
)
qqline(res, col = "firebrick", lwd = 2)
dev.off()

# Residuals vs fitted
png("assignments/homework2/q4c_residuals_vs_fitted.png", width = 900, height = 700)
par(cex.lab = 1.9, cex.axis = 1.7, mar = c(5.2, 5.2, 2.0, 1.2))
plot(
  fitted_vals,
  res,
  main = "",
  xlab = "Fitted tensile strength",
  ylab = "Residuals",
  pch = 19,
  col = "steelblue",
  cex = 1.6
)
abline(h = 0, col = "firebrick", lwd = 2)
dev.off()

# Optional numeric diagnostic
shapiro_p <- shapiro.test(res)$p.value

cat("Saved Q-Q plot to assignments/homework2/q4c_qqplot.png\n")
cat("Saved residuals-vs-fitted plot to assignments/homework2/q4c_residuals_vs_fitted.png\n")
cat(sprintf("Shapiro-Wilk p-value for residual normality: %.6f\n", shapiro_p))

if (shapiro_p > 0.05) {
  cat("Comment: Residual normality appears reasonable based on Shapiro-Wilk and the Q-Q plot.\n")
} else {
  cat("Comment: Residual normality may be questionable; inspect Q-Q plot carefully.\n")
}
cat("Comment: If residuals-vs-fitted shows random scatter around zero with no pattern, model adequacy is supported.\n")
