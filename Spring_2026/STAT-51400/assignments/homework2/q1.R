### Question 1 ###

# Etch data
data <- data.frame(
  Sequence = 1:20,
  Power = c(
    200, 220, 220, 160, 160,
    180, 200, 160, 180, 200,
    220, 220, 160, 160, 220,
    180, 180, 180, 200, 200
  )
)

# Means model
data$i <- factor(data$i)
fit <- lm(y ~ i - 1, data = data)
summary(fit)