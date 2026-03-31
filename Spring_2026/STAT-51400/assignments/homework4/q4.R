## Question 4

###########################################################################
## 1) Choose a 2^(7-2) design
###########################################################################

## Use B, C, D, E, G as the independent factors.
## Choose two four-factor interactions as generators:
##   A = BCDE
##   F = BCDG

factors <- c("A", "B", "C", "D", "E", "F", "G")
base_factors <- c("B", "C", "D", "E", "G")

des <- expand.grid(
  B = c(-1, 1),
  C = c(-1, 1),
  D = c(-1, 1),
  E = c(-1, 1),
  G = c(-1, 1)
)

des$A <- with(des, B * C * D * E)
des$F <- with(des, B * C * D * G)

des <- des[, factors]

cat("Chosen generators:\n")
cat("A = BCDE\n")
cat("F = BCDG\n")

cat("\nConstructed 2^(7-2) design:\n")
print(des)

###########################################################################
## 2) Complete defining relation
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

g1_word <- multiply_words("A", "BCDE")   # I = ABCDE
g2_word <- multiply_words("F", "BCDG")   # I = BCDFG
g12_word <- multiply_words(g1_word, g2_word)

defining_relation <- sort_words(c("I", g1_word, g2_word, g12_word))

cat("\nComplete defining relation:\n")
cat(paste(defining_relation, collapse = " = "), "\n")

###########################################################################
## 3) Complete alias structure
###########################################################################

all_effects <- "I"
for (k in seq_along(factors)) {
  all_effects <- c(
    all_effects,
    apply(combn(factors, k), 2, paste, collapse = "")
  )
}
all_effects <- sort_words(all_effects)

alias_class <- function(effect, defining_relation) {
  cls <- sapply(defining_relation, function(word) multiply_words(effect, word))
  sort_words(unique(cls))
}

alias_list <- list()
used <- character(0)

for (effect in all_effects) {
  if (!(effect %in% used)) {
    cls <- alias_class(effect, defining_relation)
    alias_list[[length(alias_list) + 1]] <- cls
    used <- c(used, cls)
  }
}

cat("\nComplete alias structure:\n")
for (cls in alias_list) {
  cat(paste(cls, collapse = " = "), "\n")
}

###########################################################################
## 4) Resolution
###########################################################################

resolution <- min(nchar(defining_relation[defining_relation != "I"]))

cat("\nResolution =", resolution, "\n")
