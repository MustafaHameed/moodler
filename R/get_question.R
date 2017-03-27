#' Get Question Key
#'
#' Get question key.
#' @param conn Connection object
#' @param question.type Char vector
#' @param quiz.id Numeric vector
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @importFrom DBI dbGetQuery

get_question_key = function(conn, question.type, quiz.id,
                            prefix = "mdl_", suppress.warnings = TRUE) {

  if (suppress.warnings) {
    suppressWarnings(dbGetQuery(
      conn = conn,
      statement = use_query(
        module = "quiz",
        query = paste0("get_", question.type, "_key"),
        prefix = prefix,
        module.id = quiz.id)))
  } else {
    dbGetQuery(
      conn = conn,
      statement = use_query(
        module = "quiz",
        query = paste0("get_", question.type, "_key"),
        prefix = prefix,
        module.id = quiz.id))
  }
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



