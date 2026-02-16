### Homework 2 - Question 1(d)
### Identify RF Power with the largest etch rate

power_seq <- c(
  200, 220, 220, 160, 160,
  180, 200, 160, 180, 200,
  220, 220, 160, 160, 220,
  180, 180, 180, 200, 200
)

etch_by_power <- list(
  `160` = c(575, 542, 530, 539, 570),
  `180` = c(565, 593, 590, 579, 610),
  `200` = c(600, 651, 610, 637, 629),
  `220` = c(725, 700, 715, 685, 710)
)

idx <- setNames(rep(0L, 4), c("160", "180", "200", "220"))
etch <- numeric(length(power_seq))
for (k in seq_along(power_seq)) {
  p <- as.character(power_seq[k])
  idx[p] <- idx[p] + 1L
  etch[k] <- etch_by_power[[p]][idx[p]]
}

data <- data.frame(Power = factor(power_seq), EtchRate = etch)

group_means <- tapply(data$EtchRate, data$Power, mean)
print(round(group_means, 4))

best_power <- names(which.max(group_means))
best_mean <- max(group_means)

cat(sprintf("\nLargest mean etch rate is at RF Power = %s W (mean = %.4f).\n", best_power, best_mean))
