### Question 1g ###

# Libraries
library(faraway)

# Load the data from the faraway package
data(prostate, package = "faraway")

# Build the design matrix for the predictors (including intercept)
x <- model.matrix(~ lcavol + lweight + svi + lbph + age + lcp + pgg45 + gleason, data = prostate)

# Define number of observations, predictors and alpha level
n <- nrow(x)
p <- ncol(x)
alpha <- 0.05

# Response vector
y <- prostate$lpsa

# Compute (X'X)^-1
xtxi <- solve(t(x) %*% x)

# Compute beta_hat: (X'X)^-1 X' y
beta_hat <- xtxi %*% t(x) %*% y

# Compute estimated response vector 
y_hat <- x %*% beta_hat

# Compute the estimated variance
sigma2_hat <- sum((y - y_hat)^2) / (n - p) 

# Compute the lower and upper bounds of the 95% confidence intervals
lower_bound <- beta_hat - qt(1 - alpha / 2, df = n - p) * sqrt(diag(sigma2_hat * xtxi))
upper_bound <- beta_hat + qt(1 - alpha / 2, df = n - p) * sqrt(diag(sigma2_hat * xtxi))

# Print the confidence intervals
print(data.frame(Lower = lower_bound, Upper = upper_bound))
