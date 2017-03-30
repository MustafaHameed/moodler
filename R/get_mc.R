#' Get multichocie (one answer) item data
#'
#' Get multichoice (one naswer) item data.
#' @param conn Connection object
#' @param attempt.id Vector of attempt ids
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @importFrom dplyr %>% left_join select mutate
#' @importFrom tidyr separate_rows

get_multichoice_one = function(conn, attempt.id, prefix = "mdl_",
                               suppress.warnings = TRUE) {

  # SQL queries
  ans = get_question_ans(
    conn = conn,
    question.type = "multichoice_one",
    attempt.id = attempt.id,
    prefix = prefix,
    suppress.warnings = suppress.warnings)

  key = get_question_key(
    conn = conn,
    question.type = "multichoice_one",
    question.id = unique(ans$question.id),
    prefix = prefix,
    suppress.warnings = suppress.warnings)

  # Determine selected
  ans_given = ans %>%
    filter_latest(answer.data = "answer") %>%
    mutate(answer.num = as.numeric(answer.id) + 1) %>%
    select(attempt.id, question.id, answer.num, answer.time)

  ans_order = ans %>%
    filter_latest(answer.data = "_order") %>%
    mutate(answer.order = count_commas(answer.id)) %>%
    select(attempt.id, question.id, answer.order, answer.id,
           order.time = answer.time)

  ans_not_blank = ans_given %>%
    left_join(ans_order, by = c("attempt.id", "question.id")) %>%
    separate_rows(answer.id, answer.order, convert = TRUE) %>%
    group_by(attempt.id, question.id) %>%
    filter(answer.time > order.time, answer.num == answer.order) %>%
    select(attempt.id, question.id, answer.id, answer.time)

  # Include blank answers
  key_expanded = expand_key(
    key = key,
    attempt.id = unique(ans$attempt.id),
    include.cols = "question.id")

  ans_tidy = key_expanded %>%
    left_join(ans_not_blank)

  # Key tidy
  key_tidy = key %>%
    mutate(answer.correct = as.numeric(answer.percent > 0)) %>%
    select(question.id, answer.id, question.text, answer.text,
           answer.correct)

  list(key = key_tidy, ans = ans_tidy)
}

#' Get multichocie (multiple answers) item data
#'
#' Get multichoice (multiple naswers) item data.
#' @param conn Connection object
#' @param quiz.id Numeric vector of length 1
#' @param attempt.id Vector of attempt ids
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @importFrom dplyr %>% left_join select mutate
#' @importFrom tidyr separate_rows

get_multichoice_multiple = function(conn, quiz.id, attempt.id, prefix = "mdl_",
                                    suppress.warnings = TRUE) {

  key = get_question_key(
    conn = conn,
    question.type = "multichoice_multiple",
    quiz.id = quiz.id,
    prefix = prefix,
    suppress.warnings = suppress.warnings)

  ans = get_question_ans(
    conn = conn,
    question.type = "multichoice_multiple",
    attempt.id = attempt.id,
    prefix = prefix,
    suppress.warnings = suppress.warnings)

  ans_answer = ans %>%
    filter_latest("grepl('choice[0-9]+', answer.data)") %>%
    mutate(order.answer = reg_match(answer.data, "[0-9]+"),
           order.answer = as.numeric(order.answer) + 1) %>%
    filter(answer.id == "1") %>%
    select(-c(answer.data, answer.id))

  ans_order = ans %>%
    filter_latest(answer.data = "_order") %>%
    mutate(order.answer = count_commas(answer.id)) %>%
    select(attempt.id, question.id, order.answer, answer.id,
           order.time = answer.time) %>%
    separate_rows(answer.id, order.answer, convert = TRUE)

  ans_tidy = ans_answer %>%
    left_join(ans_order,
              by = c("attempt.id", "question.id", "order.answer")) %>%
    group_by(attempt.id, question.id) %>%
    select(course.id, attempt.id, question.id, question.type,
           question.maxpoints.past, answer.id, answer.time) %>%
    as.data.frame()

  list(key = key, ans = ans_tidy, ans_raw = ans)
}
