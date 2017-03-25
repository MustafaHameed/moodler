#' Get truefalse item data
#'
#' Get truefalse item data.
#' @param conn Connection object
#' @param quiz.id Numeric vector of length 1
#' @param attempt.id Vector of attempt ids
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @importFrom dplyr %>% left_join select mutate

get_truefalse = function(conn, quiz.id, attempt.id, prefix = "mdl_") {

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

  ans_tidy = join_key_ans(key = key, ans = ans)

  list(key = key, ans = ans_tidy)
}

#' Get shortanswer item data
#'
#' Get shertanswer item data.
#' @param conn Connection object
#' @param quiz.id Numeric vector of length 1
#' @param attempt.id Vector of attempt ids
#' @param prefix Defaults to \code{"mdl_quiz"}
#' @importFrom dplyr %>% left_join select mutate

get_shortanswer = function(conn, quiz.id, attempt.id, prefix = "mdl_") {

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

  ans_tidy = join_key_ans(key = key, ans = ans)

  list(key = key, ans = ans_tidy)
}
