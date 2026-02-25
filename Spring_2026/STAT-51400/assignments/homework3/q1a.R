### Homework 3 - Question 1(a)
### RCBD ANOVA computed manually (no aov())

# Rows = designs (treatments), columns = regions (blocks)
y <- matrix(
  c(
    250, 350, 219, 375,  # Design 1
    400, 525, 390, 580,  # Design 2
    275, 340, 200, 310   # Design 3
  ),
  nrow = 3,
  byrow = TRUE
)
rownames(y) <- c("Design1", "Design2", "Design3")
colnames(y) <- c("NE", "NW", "SE", "SW")

a <- nrow(y)  # number of treatments
b <- ncol(y)  # number of blocks
N <- a * b

# Means required by the RCBD ANOVA formulas
grand_mean <- mean(y)
treatment_means <- rowMeans(y)
block_means <- colMeans(y)

# RCBD sums of squares using mean-based formulas
# SS_total = sum_{i,j} (y_ij - y...)^2
SS_total <- sum((y - grand_mean)^2)
# SS_treatments = b * sum_i (y_i. - y...)^2
SS_treatment <- b * sum((treatment_means - grand_mean)^2)
# SS_blocks = a * sum_j (y_.j - y...)^2
SS_block <- a * sum((block_means - grand_mean)^2)
# SS_error = SS_total - SS_treatments - SS_blocks
SS_error <- SS_total - SS_treatment - SS_block
cat(sprintf("%.2f\n\n", SS_error))

# Degrees of freedom
df_treatment <- a - 1
df_block <- b - 1
df_error <- (a - 1) * (b - 1)
df_total <- N - 1

# Mean squares
MS_treatment <- SS_treatment / df_treatment
MS_block <- SS_block / df_block
MS_error <- SS_error / df_error

# F statistics and p-values
F_treatment <- MS_treatment / MS_error
F_block <- MS_block / MS_error
p_treatment <- pf(F_treatment, df_treatment, df_error, lower.tail = FALSE)
p_block <- pf(F_block, df_block, df_error, lower.tail = FALSE)

anova_manual <- data.frame(
  Source = c("Design (Treatment)", "Region (Block)", "Error", "Total"),
  Df = c(df_treatment, df_block, df_error, df_total),
  `Sum Sq` = c(SS_treatment, SS_block, SS_error, SS_total),
  `Mean Sq` = c(MS_treatment, MS_block, MS_error, NA),
  `F value` = c(F_treatment, F_block, NA, NA),
  `Pr(>F)` = c(p_treatment, p_block, NA, NA),
  check.names = FALSE
)

cat("=== Question 1(a): Manual RCBD ANOVA ===\n\n")
cat("Data matrix (rows=treatments, cols=blocks):\n")
print(y)
cat(sprintf("\nGrand mean y... = %.6f\n\n", grand_mean))
anova_print <- anova_manual
num_cols <- sapply(anova_print, is.numeric)
anova_print[num_cols] <- lapply(anova_print[num_cols], round, 6)
print(anova_print, row.names = FALSE)

alpha <- 0.05
if (p_treatment < alpha) {
  cat(sprintf(
    "\nConclusion for design effect (alpha = %.2f): Reject H0 (p = %.6f).\n",
    alpha, p_treatment
  ))
  cat("At least one design mean response rate is different.\n")
} else {
  cat(sprintf(
    "\nConclusion for design effect (alpha = %.2f): Fail to reject H0 (p = %.6f).\n",
    alpha, p_treatment
  ))
  cat("No significant evidence of differences among design means.\n")
}

cat("\nTreatment means:\n")
print(round(treatment_means, 4))

cat("\nBlock means:\n")
print(round(block_means, 4))
