### Homework 2 - Question 3(d)
### Normal probability plot (QQ plot) of residuals

technique <- factor(rep(1:4, each = 4))
strength <- c(
  3129, 3000, 2865, 2890,
  3200, 3300, 2975, 3150,
  2800, 2900, 2985, 3050,
  2600, 2700, 2600, 2765
)

fit <- lm(strength ~ technique)
res <- resid(fit)

png("assignments/homework2/q3d_qqplot.png", width = 900, height = 700)
par(cex.lab = 1.9, cex.axis = 1.7, cex.main = 1.8, mar = c(5.2, 5.2, 2.0, 1.2))
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

cat("Saved Q-Q plot to assignments/homework2/q3d_qqplot.png\n")
cat("Interpretation guideline: points close to the line support normality.\n")
