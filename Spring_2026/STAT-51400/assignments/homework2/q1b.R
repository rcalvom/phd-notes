### Homework 2 - Question 1(b)
### Predict etch rate at RF Power = 200 for each model

# Constants from q1a (computed from Table 3.1)
mu_i <- c(`160` = 551.2, `180` = 587.4, `200` = 625.4, `220` = 707.0)
mu <- 617.75
tau <- c(`160` = -66.55, `180` = -30.35, `200` = 7.65, `220` = 89.25)
beta <- c(`(Intercept)` = 551.2, `x180` = 36.2, `x200` = 74.2, `x220` = 155.8)

# Prediction at Power = 200 using each parameterization
pred_means <- unname(mu_i["200"])
pred_effects <- mu + unname(tau["200"])
pred_reg <- unname(beta["(Intercept)"] + beta["x200"])

cat("Prediction at RF Power = 200\n")
cat(sprintf("Means model:   %.4f\n", pred_means))
cat(sprintf("Effects model: %.4f\n", pred_effects))
cat(sprintf("Regression:    %.4f\n\n", pred_reg))

same <- isTRUE(all.equal(pred_means, pred_effects)) && isTRUE(all.equal(pred_means, pred_reg))
cat("Are the three predictions the same? ", ifelse(same, "Yes", "No"), "\n", sep = "")
