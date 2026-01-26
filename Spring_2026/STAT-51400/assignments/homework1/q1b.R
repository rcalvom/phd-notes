### Question 1b ###

# Libraries
library(faraway)

# Load the data from the faraway package
data(prostate, package = "faraway")

# Create the multiple linear regression model
model <- lm(lpsa ~ lcavol + lweight + svi + lbph + age + lcp + pgg45 + gleason, data = prostate)

# Print the summary of the model
summary(model)

# Print the R-squared value
print(paste("The R-squared estimator:", summary(model)$r.squared))
