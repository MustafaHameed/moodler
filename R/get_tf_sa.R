#' Get truefalse item data
#'
#' Get truefalse item data.
#' @param conn Connection object
#' @param quiz.id Numeric vector of length 1
#' @param attempt.id Vector of attempt ids
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @importFrom dplyr %>% left_join select mutate

get_truefalse = function(conn, quiz.id, attempt.id, prefix = "mdl_",
                         suppress.warnings = TRUE) {

  key = get_question_key(
    conn = conn,
    question.type = "truefalse",
    quiz.id = quiz.id,
    prefix = prefix)

  ans = get_question_ans(
    conn = conn,
    question.type = "truefalse",
    attempt.id = attempt.id,
    prefix = prefix)

  ans_tidy = ans %>%
    group_by(attempt.id, question.id) %>%
    filter(answer.time == max(answer.time) | is.na(answer.time)) %>%
    as.data.frame()

  list(key = key, ans = ans_tidy, ans_raw = ans)
}

#' Get shortanswer item data
#'
#' Get shertanswer item data.
#' @param conn Connection object
#' @param quiz.id Numeric vector of length 1
#' @param attempt.id Vector of attempt ids
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @importFrom dplyr %>% left_join select mutate

get_shortanswer = function(conn, quiz.id, attempt.id, prefix = "mdl_",
                           suppress.warnings = TRUE) {

  key = get_question_key(
    conn = conn,
    question.type = "shortanswer",
    quiz.id = quiz.id,
    prefix = prefix)

  ans = get_question_ans(
    conn = conn,
    question.type = "shortanswer",
    attempt.id = attempt.id,
    prefix = prefix)

  ans_answer = ans %>%
    filter_latest(answer.data = "answer") %>%
    select(-c(answer.percent, answer.data))

  ans_finish = ans %>%
    filter(!is.na(answer.percent)) %>%
    rename(finish.time = answer.time) %>%
    group_by(attempt.id, question.id) %>%
    filter(finish.time == max(finish.time)) %>%
    select(attempt.id, question.id, answer.percent, finish.time)

  ans_tidy = ans_answer %>%
    left_join(ans_finish, by = c("attempt.id", "question.id")) %>%
    filter(answer.time <= finish.time) %>%
    mutate(answer.id = NA_real_) %>%
    as.data.frame()

  list(key = key, ans = ans_tidy, ans_raw = ans)
}
