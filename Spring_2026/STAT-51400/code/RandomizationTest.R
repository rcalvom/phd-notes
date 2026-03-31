
## Randomization (permutation) test for the plasma etching data
## Goal: test whether etch rate depends on Power (one way design, 4 groups, 5 reps each)

## Exact randomization test by enumerating all permutations

## Data
y <- c(
  575, 542, 530, 539, 570,
  565, 593, 590, 579, 610,
  600, 651, 610, 637, 629,
  725, 700, 715, 685, 710
)

n <- length(y)
stopifnot(n == 20)

## Observed grouping
group_obs <- factor(rep(1:4, each = 5))

## Observed F statistic
obs_F <- summary(aov(y ~ group_obs))[[1]][1, "F value"]

## Precompute total SS
grand_mean <- mean(y)
SST <- sum((y - grand_mean)^2)

## Counter
extreme_count <- 0
total_count <- 0

## Enumerate all combinations:
## Step 1: choose indices for group 1
for (g1 in combn(1:20, 5, simplify = FALSE)) {
  
  remaining1 <- setdiff(1:20, g1)
  
  ## Step 2: choose indices for group 2
  for (g2 in combn(remaining1, 5, simplify = FALSE)) {
    
    remaining2 <- setdiff(remaining1, g2)
    
    ## Step 3: choose indices for group 3
    for (g3 in combn(remaining2, 5, simplify = FALSE)) {
      
      ## Remaining automatically group 4
      g4 <- setdiff(remaining2, g3)
      
      ## Compute between group SS efficiently
      m1 <- mean(y[g1])
      m2 <- mean(y[g2])
      m3 <- mean(y[g3])
      m4 <- mean(y[g4])
      
      SSB <- 5 * ((m1 - grand_mean)^2 +
                    (m2 - grand_mean)^2 +
                    (m3 - grand_mean)^2 +
                    (m4 - grand_mean)^2)
      
      SSE <- SST - SSB
      
      F_stat <- (SSB / 3) / (SSE / 16)
      
      total_count <- total_count + 1
      
      if (F_stat >= obs_F) {
        extreme_count <- extreme_count + 1
      }
    }
  }
}

p_value <- extreme_count / total_count

cat("Total permutations =", total_count, "\n")
cat("Observed F =", obs_F, "\n")
cat("Exact permutation p value =", p_value, "\n")


# Randomization test by a fixed number (B) of permutations

set.seed(514)

## 1) Enter the data
dat <- data.frame(
  power = factor(rep(c(160, 180, 200, 220), each = 5)),
  y = c(
    575, 542, 530, 539, 570,
    565, 593, 590, 579, 610,
    600, 651, 610, 637, 629,
    725, 700, 715, 685, 710
  )
)

## 2) Choose a test statistic
## Option A: ANOVA F statistic (omnibus difference among group means)
obs_F <- summary(aov(y ~ power, data = dat))[[1]]["power", "F value"]

## Option B: max minus min of group means (also omnibus, more direct)
group_means <- tapply(dat$y, dat$power, mean)
obs_range_means <- max(group_means) - min(group_means)

## 3) Permutation scheme (randomization test)
## Shuffle outcomes across units while keeping group sizes fixed
B <- 10000

perm_F <- numeric(B)


for (b in seq_len(B)) {
  y_perm <- sample(dat$y, replace = FALSE)
  dat_perm <- dat
  dat_perm$y <- y_perm
  
  perm_F[b] <- summary(aov(y ~ power, data = dat_perm))[[1]]["power", "F value"]
}

## 4) P values
## For F and range of means, larger values are more extreme
p_F <- (1 + sum(perm_F >= obs_F)) / (B + 1)



## 5) Optional: show a quick diagnostic plot
hist(perm_F, breaks = 60, main = "Permutation distribution of F", xlab = "F")
abline(v = obs_F, lwd = 2)


