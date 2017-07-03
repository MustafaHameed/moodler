#' Get multichocie (one answer) item data
#'
#' Get multichoice (one naswer) item data.
#' @param conn Connection object
#' @param attempt.id Vector of attempt ids
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @importFrom dplyr %>% left_join right_join select mutate group_by ungroup
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

  # Tidy-up key and include blank answers
  key_tidy = key %>%
    group_by(question.id) %>%
    mutate(answer.correct = as.numeric(answer.percent > 0),
           answer.num = answer.id - min(answer.id) + 1) %>%
    select(question.id, answer.id, question.name, question.text, question.type,
           answer.text, answer.num, answer.correct) %>%
    ungroup()

  key_expanded = expand_key(
    key = key,
    attempt.id = attempt.id,
    include.cols = "question.id")

  key_num = select(key_tidy, question.id, answer.id, answer.num)

  # Tidy answers
  ans_tidy = ans_given %>%
    left_join(ans_order, by = c("attempt.id", "question.id")) %>%
    separate_rows(answer.id, answer.order, convert = TRUE) %>%
    group_by(attempt.id, question.id) %>%
    filter(answer.time > order.time, answer.num == answer.order) %>%
    select(attempt.id, question.id, answer.time, answer.id) %>%
    right_join(key_expanded, by = c("attempt.id", "question.id")) %>%
    left_join(key_num, by = c("question.id", "answer.id"))

  list(ans = select(ans_tidy, -answer.id),
       key = select(key_tidy, -answer.id)
  )
}

#' Get multichocie (multiple answers) item data
#'
#' Get multichoice (multiple naswers) item data.
#' @param conn Connection object
#' @param quiz.id Numeric vector of length 1
#' @param attempt.id Vector of attempt ids
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @importFrom dplyr %>% left_join select mutate group_by ungroup right_join
#' @importFrom tidyr separate_rows

get_multichoice_multiple = function(conn, quiz.id, attempt.id, prefix = "mdl_",
                                    suppress.warnings = TRUE) {

  # SQL queries
  ans = get_question_ans(
    conn = conn,
    question.type = "multichoice_multiple",
    attempt.id = attempt.id,
    prefix = prefix,
    suppress.warnings = suppress.warnings)

  key = get_question_key(
    conn = conn,
    question.type = "multichoice_multiple",
    question.id = unique(ans$question.id),
    prefix = prefix,
    suppress.warnings = suppress.warnings)

  # Determine selected
  ans_given = ans %>%
    filter_latest("grepl('choice[0-9]+', answer.data)") %>%
    mutate(answer.order = as.numeric(reg_match(answer.data, "[0-9]+")) + 1,
           answer.num = as.numeric(answer.id)) %>%
    select(attempt.id, question.id, answer.num, answer.order, answer.time)

  ans_order = ans %>%
    filter_latest(answer.data = "_order") %>%
    mutate(answer.order = count_commas(answer.id)) %>%
    select(attempt.id, question.id, answer.order, answer.id,
           order.time = answer.time) %>%
    separate_rows(answer.id, answer.order, convert = TRUE)

  # Tidy-up key and include blank answers
  key_expanded = expand_key(
    key = key,
    attempt.id = attempt.id,
    include.cols = c("question.id", "answer.id"))

  # Tidy key
  key_tidy = key %>%
    mutate(question.id = paste(question.id, answer.id, sep = "/"),
           question.text = paste(question.text, answer.text, sep = ": "),
           answer.correct = if_else(answer.percent > 0, "1,0", "0,1"),
           answer.num = "1,0") %>%
    separate_rows(answer.num, answer.correct, convert = TRUE) %>%
    mutate(answer.text = if_else(answer.num == 1, "True", "False")) %>%
    select(question.id, question.name, question.text, question.type,
           answer.text, answer.num, answer.correct)

  key_num = select(key_tidy, question.id, answer.num)

  # Tidy-up answers
  ans_tidy = ans_given %>%
    left_join(ans_order, by = c("attempt.id", "question.id", "answer.order")) %>%
    group_by(attempt.id, question.id) %>%
    select(attempt.id, question.id, answer.time, answer.id, answer.num) %>%
    right_join(
      key_expanded,
      by = c("attempt.id", "question.id", "answer.id")) %>%
    ungroup() %>%
    mutate(question.id = paste(question.id, answer.id, sep = "/")) %>%
    left_join(
      key_num,
      by = c("question.id", "answer.num")) %>%
    select(-answer.id)

  list(ans = ans_tidy,
       key = key_tidy
  )
}
