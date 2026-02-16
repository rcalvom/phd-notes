### Homework 2 - Question 3(b) - Software-only ANOVA (R)

technique <- factor(rep(1:4, each = 4))
strength <- c(
  3129, 3000, 2865, 2890,
  3200, 3300, 2975, 3150,
  2800, 2900, 2985, 3050,
  2600, 2700, 2600, 2765
)
data <- data.frame(Technique = technique, Strength = strength)
fit <- lm(Strength ~ Technique, data = data)
print(anova(fit))
