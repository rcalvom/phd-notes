## Question 3

###########################################################################
## 1) Enter the treatment combinations and convert to coded levels
###########################################################################

runs <- c("d", "ae", "b", "abde", "cde", "ac", "bce", "abcd")
factors <- c("A", "B", "C", "D", "E")

label_to_levels <- function(label, factors) {
  lev <- rep(-1, length(factors))
  names(lev) <- factors

  high_fac <- toupper(strsplit(label, "")[[1]])
  lev[high_fac] <- 1
  lev
}

X_fac <- t(sapply(runs, label_to_levels, factors = factors))

dat <- data.frame(
  run = runs,
  X_fac,
  row.names = NULL,
  check.names = FALSE
)

cat("Design table:\n")
print(dat)

###########################################################################
## 2) Basic design information
###########################################################################

n_factors <- length(factors)
n_runs <- nrow(dat)
n_independent <- as.integer(log2(n_runs))

cat("\n(a) Number of factors investigated =", n_factors, "\n")
cat("(b) Number of independent factors =", n_independent, "\n")

###########################################################################
## 3) Choose independent factors and identify generators
###########################################################################

## One convenient choice is to treat A, B, and C as the independent factors.
## Then the observed run table shows:
##   D = AB
##   E = -AC

dat$AB <- with(dat, A * B)
dat$neg_AC <- with(dat, -A * C)

cat("\n(c) Choose A, B, C as independent factors.\n")
cat("    Then the dependent-factor generators are D = AB and E = -AC.\n")
cat("    Check:\n")
print(dat[, c("run", "D", "AB", "E", "neg_AC")])

###########################################################################
## 4) Principal fraction?
###########################################################################

is_principal <- any(apply(dat[, factors], 1, function(z) all(z == -1)))

cat("\n(d) Is this a principal fraction? ", ifelse(is_principal, "Yes", "No"), "\n", sep = "")
if (!is_principal) {
  cat("    The all-low treatment (1) is not in the design, so this is not the principal fraction.\n")
}

###########################################################################
## 5) Complete defining relation and alias structure
###########################################################################

word_to_letters <- function(word) {
  if (word == "I") {
    character(0)
  } else {
    strsplit(word, "")[[1]]
  }
}

reduce_word <- function(letters) {
  if (length(letters) == 0) {
    return("I")
  }

  letters <- sort(letters)
  keep <- names(which(table(letters) %% 2 == 1))

  if (length(keep) == 0) {
    "I"
  } else {
    paste(keep, collapse = "")
  }
}

multiply_words <- function(w1, w2) {
  reduce_word(c(word_to_letters(w1), word_to_letters(w2)))
}

word_order <- function(words) {
  out <- nchar(words)
  out[words == "I"] <- 0
  out
}

sort_words <- function(words) {
  words[order(word_order(words), words)]
}

## From D = AB and E = -AC:
##   I = ABD
##   I = -ACE
## Their product gives:
##   I = -BCDE

def_words <- c("I", "ABD", "ACE", "BCDE")
def_signs <- c(1, 1, -1, -1)

cat("\n(e) Complete defining relation:\n")
cat("    I = ABD = -ACE = -BCDE\n")

all_effects <- c("I")
for (k in seq_along(factors)) {
  all_effects <- c(
    all_effects,
    apply(combn(factors, k), 2, paste, collapse = "")
  )
}
all_effects <- sort_words(all_effects)

alias_class <- function(effect, def_words, def_signs) {
  out <- mapply(
    function(word, sign) {
      aliased_word <- multiply_words(effect, word)
      list(effect = aliased_word, sign = sign)
    },
    def_words,
    def_signs,
    SIMPLIFY = FALSE
  )

  ord <- order(
    sapply(out, function(z) if (z$effect == "I") 0 else nchar(z$effect)),
    sapply(out, function(z) z$effect)
  )
  out[ord]
}

canon <- function(effect, sign) {
  paste0(if (sign < 0) "-" else "+", effect)
}

seen <- character(0)
alias_list <- list()

for (effect in all_effects) {
  if (!(canon(effect, 1) %in% seen || canon(effect, -1) %in% seen)) {
    cls <- alias_class(effect, def_words, def_signs)
    alias_list[[length(alias_list) + 1]] <- cls

    for (z in cls) {
      seen <- c(seen, canon(z$effect, z$sign), canon(z$effect, -z$sign))
    }
  }
}

cat("    Alias structure:\n")
for (cls in alias_list) {
  cls_text <- sapply(cls, function(z) {
    paste0(if (z$sign < 0) "-" else "", z$effect)
  })
  cat("    ", paste(cls_text, collapse = " = "), "\n", sep = "")
}

###########################################################################
## 6) Resolution
###########################################################################

resolution <- min(nchar(def_words[def_words != "I"]))

cat("\n(f) Resolution =", resolution, "\n")
