# STAT 514 - Midterm 1 - Question 1(c)
# Choose the correct critical F-value

alpha <- 0.05

df1 <- 2   # numerator df = a - 1 = 3 - 1
df2 <- 12  # denominator df = N - a = 15 - 3

F_crit <- qf(1 - alpha, df1 = df1, df2 = df2)

cat("=== Question 1(c) ===\n")
cat(sprintf("Critical value: qf(0.95, df1=%d, df2=%d) = %.4f\n", df1, df2, F_crit))
cat("Correct option: (a)\n\n")

# Compare against all listed options in the exam statement
opts <- data.frame(
  option = c("a", "b", "c", "d"),
  df1 = c(2, 2, 3, 3),
  df2 = c(12, 14, 12, 14)
)
opts$value <- qf(0.95, df1 = opts$df1, df2 = opts$df2)
opts_print <- opts
opts_print$value <- round(opts_print$value, 4)
print(opts_print, row.names = FALSE)
