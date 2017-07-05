# Are all list elements named?
all_named = function(x) {
  all(nchar(names(x)) > 0, length(names(x)) > 0)
}

# Return matched regular expression (a la stringr::str_match)
reg_match = function(string, pattern) {
  match_position = gregexpr(pattern = pattern, text = string)
  match_text = regmatches(string, match_position)
  unlist(match_text)
}

# Return comma-separated cummulative count of comma-separated items
# i.e. tre,tru,tri will return 1,2,3
count_commas = function(x) {
  paste(
    0:length(reg_match(x, ",+")) + 1,
    collapse = ","
  )
}

# Remove html tags
untag = function(x, drop.newline = TRUE) {
  if (class(x) != "character") stop("Input must be of class 'character'")
  if (drop.newline == T) {
    gsub(pattern = "<[^>]*>\n*", replacement = "", x)
  } else {
    x = gsub(pattern = "<[^>]*>", replacement = "", x)
    gsub(pattern = "\n{2,}", replacement = "\n", x)
  }
}

# Count individual words (space-based, no fancy removal of stopwords)
word_count = function(x) {
  if (class(x) != "character") stop("Input must be of class 'character'")
  x.words = lapply(x, strsplit, split = " ")
  x.count = rapply(x.words, length)
  unlist(x.count)
}


