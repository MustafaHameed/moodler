#' Get multichocie (one answer) item data
#'
#' Get multichoice (one naswer) item data.
#' @param conn Connection object
#' @param quiz.id Numeric vector of length 1
#' @param attempt.id Vector of attempt ids
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @importFrom dplyr %>% left_join select mutate
#' @importFrom tidyr separate_rows

get_multichoice_one = function(conn, quiz.id, attempt.id, prefix = "mdl_",
                               suppress.warnings = TRUE) {

  key = get_question_key(
    conn = conn,
    question.type = "multichoice_one",
    quiz.id = quiz.id,
    prefix = prefix,
    suppress.warnings = suppress.warnings)

  ans = get_question_ans(
    conn = conn,
    question.type = "multichoice_one",
    attempt.id = attempt.id,
    prefix = prefix,
    suppress.warnings = suppress.warnings)

  ans_answer = ans %>%
    filter_latest(answer.data = "answer") %>%
    mutate(answer.n = as.numeric(answer.id) + 1) %>%
    select(-c(answer.data, answer.id))

  ans_order = ans %>%
    filter_latest(answer.data = "_order") %>%
    mutate(order.answer = count_commas(answer.id)) %>%
    select(attempt.id, question.id, order.answer, answer.id,
           order.time = answer.time)

  ans_tidy =
    left_join(ans_answer, ans_order,
              by = c("attempt.id", "question.id")) %>%
    group_by(attempt.id, question.id) %>%
    filter(answer.time > order.time) %>%
    separate_rows(answer.id, order.answer, convert = TRUE) %>%
    filter(answer.n == order.answer) %>%
    select(course.id, attempt.id, question.id, question.type,
           question.maxpoints.past, answer.id, answer.time) %>%
    as.data.frame()

  list(key = key, ans = ans_tidy, ans_raw = ans)
}

#' Get multichocie (multiple answers) item data
#'
#' Get multichoice (multiple naswers) item data.
#' @param conn Connection object
#' @param quiz.id Numeric vector of length 1
#' @param attempt.id Vector of attempt ids
#' @param prefix Defaults to \code{"mdl_quiz"}
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

  ans_tidy =
    left_join(ans_answer, ans_order,
              by = c("attempt.id", "question.id", "order.answer")) %>%
    group_by(attempt.id, question.id) %>%
    select(course.id, attempt.id, question.id, question.type,
           question.maxpoints.past, answer.id, answer.time) %>%
    as.data.frame()

  list(key = key, ans = ans_tidy, ans_raw = ans)
}
