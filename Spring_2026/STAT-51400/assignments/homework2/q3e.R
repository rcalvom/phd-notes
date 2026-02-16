### Homework 2 - Question 3(e)
### Residuals versus fitted values plot

technique <- factor(rep(1:4, each = 4))
strength <- c(
  3129, 3000, 2865, 2890,
  3200, 3300, 2975, 3150,
  2800, 2900, 2985, 3050,
  2600, 2700, 2600, 2765
)

fit <- lm(strength ~ technique)
fitted_vals <- fitted(fit)
res <- resid(fit)

png("assignments/homework2/q3e_residuals_vs_fitted.png", width = 900, height = 700)
par(cex.lab = 1.9, cex.axis = 1.7, cex.main = 1.8, mar = c(5.2, 5.2, 2.0, 1.2))
plot(
  fitted_vals, res,
  pch = 19,
  col = "steelblue",
  cex = 1.6,
  xlab = "Fitted tensile strength",
  ylab = "Residuals",
  main = ""
)
abline(h = 0, col = "firebrick", lwd = 2)
dev.off()

cat("Saved residuals-vs-fitted plot to assignments/homework2/q3e_residuals_vs_fitted.png\n")
cat("Interpretation guideline: random scatter around 0 suggests constant variance and adequate model form.\n")
