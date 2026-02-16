### Homework 2 - Question 3(b)
### Reproduce ANOVA table by hand and verify with software output

technique <- factor(rep(1:4, each = 4))
strength <- c(
  3129, 3000, 2865, 2890,
  3200, 3300, 2975, 3150,
  2800, 2900, 2985, 3050,
  2600, 2700, 2600, 2765
)

data <- data.frame(Technique = technique, Strength = strength)

# Counts
a <- nlevels(data$Technique)
N <- nrow(data)
n_i <- as.numeric(table(data$Technique))

# Group totals, group means, grand mean
group_totals <- tapply(data$Strength, data$Technique, sum)
group_means <- tapply(data$Strength, data$Technique, mean)
grand_mean <- mean(data$Strength)

# Manual ANOVA quantities
ss_total <- sum((data$Strength - grand_mean)^2)
ss_treat <- sum(n_i * (group_means - grand_mean)^2)
ss_error <- ss_total - ss_treat

df_treat <- a - 1
df_error <- N - a
df_total <- N - 1

ms_treat <- ss_treat / df_treat
ms_error <- ss_error / df_error
f_stat <- ms_treat / ms_error

manual_tbl <- data.frame(
  Source = c("Technique", "Error", "Total"),
  Df = c(df_treat, df_error, df_total),
  SumSq = c(ss_treat, ss_error, ss_total),
  MeanSq = c(ms_treat, ms_error, NA_real_),
  F = c(f_stat, NA_real_, NA_real_)
)

cat("=== Group totals and means ===\n")
print(data.frame(
  Technique = names(group_totals),
  Total = as.numeric(group_totals),
  Mean = round(as.numeric(group_means), 4)
), row.names = FALSE)
cat(sprintf("\nGrand mean = %.4f\n", grand_mean))

cat("\n=== Manual ANOVA table ===\n")
manual_out <- manual_tbl
manual_out[, c("SumSq", "MeanSq", "F")] <- round(manual_out[, c("SumSq", "MeanSq", "F")], 4)
print(manual_out, row.names = FALSE)

cat("\n=== Software ANOVA table (anova(lm)) ===\n")
fit <- lm(Strength ~ Technique, data = data)
print(anova(fit))
