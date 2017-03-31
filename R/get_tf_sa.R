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

  # SQL queries
  ans = get_question_ans(
    conn = conn,
    question.type = "truefalse",
    attempt.id = attempt.id,
    prefix = prefix)

  key = get_question_key(
    conn = conn,
    question.type = "truefalse",
    question.id = unique(ans$question.id),
    prefix = prefix)

  # Tidy key
  key_tidy = key %>%
    mutate(answer.num = as.numeric(answer.text == "True")) %>%
    select(question.id, question.text, question.type,
           answer.text, answer.num, answer.correct = answer.percent)

  key_expanded = expand_key(
    key = key,
    attempt.id = unique(ans$attempt.id),
    include.cols = "question.id"
  )

  key_num = select(key_tidy, question.id, answer.num)

  # Tidy answer
  ans_latest = ans %>%
    group_by(attempt.id, question.id) %>%
    filter(answer.time == max(answer.time) | is.na(answer.time)) %>%
    ungroup()

  ans_tidy = ans_latest %>%
    mutate(answer.num = as.numeric(answer.text == "True")) %>%
    right_join(key_expanded) %>%
    left_join(key_num) %>%
    select(attempt.id, question.id, answer.time, answer.num)

  list(key = key_tidy, ans = ans_tidy)
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

  # SQL queries
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
