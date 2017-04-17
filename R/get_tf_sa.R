#' Get truefalse item data
#'
#' Get truefalse item data.
#' @param conn Connection object
#' @param attempt.id Vector of attempt ids
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @importFrom dplyr %>% left_join select mutate

get_truefalse = function(conn, attempt.id, prefix = "mdl_",
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
    mutate(answer.num = rep(0:1, n()/2)) %>%
    select(question.id, question.text, question.type,
           answer.text, answer.num, answer.correct = answer.percent)

  key_expanded = expand_key(
    key = key,
    attempt.id = attempt.id,
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
    right_join(key_expanded, by = c("attempt.id", "question.id")) %>%
    left_join(key_num, by = c("question.id", "answer.num")) %>%
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
  ans = get_question_ans(
    conn = conn,
    question.type = "shortanswer",
    attempt.id = attempt.id,
    prefix = prefix)

  key = get_question_key(
    conn = conn,
    question.type = "shortanswer",
    question.id = unique(ans$question.id),
    prefix = prefix)

  # Tidy key
  key_tidy = key %>%
    mutate(answer.num = "0,1",
           answer.correct = answer.num) %>%
    separate_rows(answer.num, answer.correct, convert = TRUE) %>%
    mutate(answer.text = if_else(answer.num == 1, "Correct", "Incorrect")) %>%
    select(question.id, question.text, question.type,
           answer.text, answer.num, answer.correct) %>%
    unique()

  key_expanded = expand_key(
    key = key,
    attempt.id = attempt.id,
    include.cols = "question.id"
  )

  key_num = select(key_tidy, question.id, answer.num)

  # Tidy-up answers
  ans_answer = ans %>%
    filter_latest(answer.data = "answer") %>%
    select(-c(answer.percent, answer.data))

  ans_finish = ans %>%
    filter(!is.na(answer.percent)) %>%
    group_by(attempt.id, question.id) %>%
    filter(answer.time == max(answer.time))

  ans_tidy = ans_finish %>%
    mutate(answer.num = as.numeric(answer.percent > 0)) %>%
    select(attempt.id, question.id, answer.time, answer.num) %>%
    right_join(key_expanded, by = c("attempt.id", "question.id"))

  list(key = key_tidy, ans = ans_tidy)
}
