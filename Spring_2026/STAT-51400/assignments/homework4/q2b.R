## Question 2(b)

###########################################################################
## 1) Independent generators and complete defining relation
###########################################################################

factors <- c("A", "B", "C", "D", "E")
g1 <- "ACE"
g2 <- "BDE"

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

defining_relation <- sort_words(c("I", g1, g2, multiply_words(g1, g2)))

cat("Complete defining relation:\n")
cat(paste(defining_relation, collapse = " = "), "\n")

###########################################################################
## 2) Build all effects for a 2^(5-2) design
###########################################################################

all_effects <- "I"
for (k in seq_along(factors)) {
  all_effects <- c(
    all_effects,
    apply(combn(factors, k), 2, paste, collapse = "")
  )
}
all_effects <- sort_words(all_effects)

###########################################################################
## 3) Alias classes
###########################################################################

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

cat("\nAlias structure:\n")
for (cls in alias_list) {
  cat(paste(cls, collapse = " = "), "\n")
}
