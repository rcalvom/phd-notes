### Question 1a ###

# Libraries
library(faraway)

# Load the data from the faraway package
data(prostate, package = "faraway")

# Create the linear model
model <- lm(lpsa ~ lcavol, data = prostate)

# Print the summary of the model
summary(model)

# Print the R-squared value
print(paste("The R-squared:", summary(model)$r.squared))
