#' Get Question Key
#'
#' Get question key.
#' @param conn Connection object
#' @param question.type Char vector
#' @param quiz.id Numeric vector
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @importFrom DBI dbGetQuery

get_question_key = function(conn, question.type, quiz.id, prefix = "mdl_") {
  suppressWarnings(
    dbGetQuery(
      conn = conn,
      statement = use_query(
        module = "quiz",
        query = paste0("get_", question.type, "_key"),
        prefix = prefix,
        module.id = quiz.id
      )
    )
  )
}

#' Get Question Answer
#'
#' Get question answer.
#' @param conn Connection object
#' @param question.type Char vector
#' @param attempt.id Numeric vector
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @importFrom DBI dbGetQuery

get_question_ans = function(conn, question.type, attempt.id, prefix = "mdl_") {
  suppressWarnings(
    dbGetQuery(
      conn = conn,
      statement = use_query(
        module = "quiz",
        query = paste0("get_", question.type, "_ans"),
        prefix = prefix,
        attempt.id = attempt.id
      )
    )
  )
}

#' Join answers and keys
#'
#' This should work for: tf, sa. Questions that are missing will be replaced by
#' NA records.
#' @param key Data from get_[question type]_key query
#' @param ans Data from get_[question type]_ans query
#' @importFrom dplyr %>% select starts_with left_join mutate filter group_by

join_key_ans = function(key, ans) {
  key_ans = has_answered(key, ans)
  key_ans %>%
    left_join(ans) %>%
    left_join(key) %>%
    group_by(attempt.id, question.id) %>%
    mutate(answer.time = as.POSIXct(answer.time)) %>%
    filter(answer.time == max(answer.time) | is.na(answer.time)) %>%
    as.data.frame()
}

has_answered = function(key, ans) {

  questions = key %>%
    select(-starts_with("answer")) %>%
    unique()

  attempts = ans %>%
    select(user.id, attempt.id) %>%
    unique()

  # Get all combinations of attempt x question
  att_que =
    expand.grid(
      attempt.id = unique(ans$attempt.id),
      question.id = unique(key$question.id)
    )

  att_que %>%
    left_join(questions, by = "question.id") %>%
    left_join(attempts, by = "attempt.id")
}
