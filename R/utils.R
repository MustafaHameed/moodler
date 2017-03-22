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
