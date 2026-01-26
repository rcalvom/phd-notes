### Question 1e ###

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

# Compute t statistic
t <- beta_hat / diag(sigma2_hat * xtxi)^0.5

# Now compute the two-sided p-values
p_value <- 2 * pt(-abs(t), df = n - p)

# Finally, print if the p-values are less than alpha
significant <- p_value < alpha

# Print the t-statistics and the results
print(t)
print(significant)
