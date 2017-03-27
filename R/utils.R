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
