### Question 1b ###

# Libraries
library(faraway)

# Load the data from the faraway package
data(prostate, package = "faraway")

# Build the design matrix for the predictors (including intercept)
x <- model.matrix(~ lcavol + lweight + svi + lbph + age + lcp + pgg45 + gleason, data = prostate)

# Response vector
y <- prostate$lpsa

# Compute (X'X)^-1
xtxi <- solve(t(x) %*% x)

# Compute and print the OLS coefficients: (X'X)^-1 X' y
print(xtxi %*% t(x) %*% y)
