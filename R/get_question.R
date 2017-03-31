# Standard data.frame
# This is how data for every item type should look like after import:

# ANSWERS
# attempt.id [numeric]
# question.id [numeric/character] -hm...
# answer.time [POSIXct]
# answer.num [integer]

# KEY
# question.id [numeric/character] -hm...
# question.text [character, values True/False or the actual text]
# question.type [character]
# answer.text [character]
# answer.num [integer]
# answer.correct [integer]

#' Get Question Key
#'
#' Get question key.
#' @param conn Connection object
#' @param question.type Char vector
#' @param question.id Numeric vector
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @importFrom DBI dbGetQuery

get_question_key = function(conn, question.type, question.id,
                            prefix = "mdl_", suppress.warnings = TRUE) {

  if (suppress.warnings) {
    key = suppressWarnings(dbGetQuery(
      conn = conn,
      statement = use_query(
        module = "quiz",
        query = paste0("get_", question.type, "_key"),
        prefix = prefix,
        question.id = question.id)))
  } else {
    key = dbGetQuery(
      conn = conn,
      statement = use_query(
        module = "quiz",
        query = paste0("get_", question.type, "_key"),
        prefix = prefix,
        question.id = question.id))
  }

  key$question.text = remove_tags(key$question.text)
  key$answer.text = remove_tags(key$answer.text)
  key
}

remove_tags = function(x) {
  stopifnot(is.character(x))
  gsub("(<[^>]+>|&nbsp;)", "", x)
}

#' Get Question Answer
#'
#' Get question answer.
#' @param conn Connection object
#' @param question.type Char vector
#' @param attempt.id Numeric vector
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @importFrom DBI dbGetQuery

get_question_ans = function(conn, question.type, attempt.id,
                            prefix = "mdl_", suppress.warnings = TRUE) {

  message("Fething: ", question.type)

  if (suppress.warnings) {
    ans = suppressWarnings(dbGetQuery(
      conn = conn,
      statement = use_query(
        module = "quiz",
        query = paste0("get_", question.type, "_ans"),
        prefix = prefix,
        attempt.id = attempt.id)))
  } else {
    ans = dbGetQuery(
      conn = conn,
      statement = use_query(
        module = "quiz",
        query = paste0("get_", question.type, "_ans"),
        prefix = prefix,
        attempt.id = attempt.id))
  }
  ans$answer.time = as.POSIXct(ans$answer.time)
  ans
}

expand_key = function(key, attempt.id, include.cols) {
  key %>%
    select_(.dots = include.cols) %>%
    replicate(n = length(attempt.id), simplify = FALSE) %>%
    setNames(attempt.id) %>%
    bind_rows(.id = "attempt.id") %>%
    unique() %>%
    mutate(attempt.id = as.numeric(attempt.id))
}

dots_to_string = function(...) {
  if (is.null(names(list(...))))
    unlist(list(...))
  else
    paste(names(list(...)), "=='", unlist(list(...)), "'", sep = "")
}

filter_latest = function(x, ...) {
  filter_args = dots_to_string(...)
  x %>%
    filter_(filter_args) %>%
    group_by(attempt.id, question.id) %>%
    filter(answer.time == max(answer.time))
}



