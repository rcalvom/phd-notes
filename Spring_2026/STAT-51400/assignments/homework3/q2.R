power <- factor(rep(c(160, 180, 200, 220), each = 5))
etch_rate <- c(
  575, 542, 530, 539, 570,  # 160 W
  565, 593, 590, 579, 610,  # 180 W
  600, 651, 610, 637, 629,  # 200 W
  725, 700, 715, 685, 710   # 220 W
)
# One-way ANOVA F statistic
f_stat_oneway <- function(y, g) {
  n <- length(y)
  group_means <- tapply(y, g, mean)
  group_sizes <- tapply(y, g, length)
  grand_mean <- mean(y)
  ss_treatment <- sum(group_sizes * (group_means - grand_mean)^2)
  ss_total <- sum((y - grand_mean)^2)
  ss_error <- ss_total - ss_treatment
  a <- nlevels(g)
  df_tr <- a - 1
  df_e <- n - a
  ms_tr <- ss_treatment / df_tr
  ms_e <- ss_error / df_e
  ms_tr / ms_e
}
f_obs <- f_stat_oneway(etch_rate, power)
set.seed(22)
B <- 1000000
f_perm <- numeric(B)
for (b in seq_len(B)) {
  power_perm <- sample(power, replace = FALSE)
  f_perm[b] <- f_stat_oneway(etch_rate, power_perm)
}
p_value <- sum(f_perm >= f_obs) / B
alpha <- 0.05
decision <- if (p_value < alpha) {
  "Reject H0: mean etch rates are not all equal "
} else {
  "Fail to reject H0: insufficient evidence."
}
cat("=== Question 2: Randomization Test (Etch Rate) ===\n")
cat(sprintf("Observed F statistic = %.6f\n", f_obs))
cat(sprintf("Permutations (B) = %d\n", B))
cat(sprintf("Randomization p-value = %.2e\n", p_value))
cat(sprintf("Decision at alpha = %.2f: %s\n", alpha, decision))
