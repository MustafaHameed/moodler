#' Get Quiz Data
#'
#' Fetch item data from quiz.
#' @param x An object of class \code{"mdl_quiz"}
#' @param attempt Defaults to \code{"first"}; \code{"all"} and \code{"last"} are also allowed, or a numeric vector specifying attempt IDs
#' @param question.type Char vector, if \code{NULL}, all items regardless of type will be fetched
#' @param prefix Defaults to \code{"mdl_"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @param ... Further arguments passed on to methods
#' @export

get_module_data.mdl_quiz = function(x, attempt = "first",
                                    question.type = NULL,
                                    distractors = TRUE,
                                    prefix = "mdl_",
                                    suppress.warnings = TRUE,
                                    ...) {

  if (!nrow(x$attempts)) {
    warning("No attempts: aborted", call. = FALSE)
    return()
  }

  available_attempts = get_attempt_id(
    x = x$attempts,
    attempt = attempt)

  if (is.null(question.type)) {
    available_questions = unique(x$questions$question.type)
  } else if (!all(question.type %in% x$questions$question.type)) {
    not_present = dplyr::setdiff(question.type, x$questions$question.type)
    stop(not_present, " are not present in this quiz", call. = FALSE)
  } else {
    available_questions = question.type
  }

  # Fetch item-level data
  items = get_question_ans(
    conn = x$connection,
    attempt.id = available_attempts,
    question.type = "allquestions",
    prefix = prefix,
    suppress.warnings = suppress.warnings
  )

  items_tidy = items %>%
    select(attempt.id, question.id, answer.time, answer.percent) %>%
    left_join(x$questions, by = "question.id") %>%
    select(attempt.id,
           question.type, question.id, question.name, question.text,
           page.number, slot.number,
           answer.time, answer.percent)

  if (!distractors)
    return(
      structure(
        .Data = list(
          settings = x$settings,
          attempts = x$attempts,
          items = items_tidy),
        class = "mdl_quiz_data"
      )
    )

  # Fetch distractor-level data
  distractors = lapply(
    X = available_questions,
    FUN = function(this_type) {
      this_fun = paste0("get_", this_type)
      if (exists(x = this_fun, mode = "function")) {
        do.call(
          what = this_fun,
          args = list(
            conn = x$connection, attempt.id = available_attempts,
            prefix = prefix, suppress.warnings = suppress.warnings))}
    })

  names(distractors) = available_questions
  distractors_tidy = distractors[!sapply(distractors, is.null)]

  structure(
    .Data = list(
      settings = x$settings,
      attempts = x$attempts,
      items = items_tidy,
      distractors = distractors_tidy),
    class = "mdl_quiz_data"
  )
}

get_attempt_id = function(x, attempt = "first") {

  stopifnot(any(
    attempt %in% c("first", "last", "all"),
    is.numeric(attempt)
  ))

  if (is.character(attempt)) {
    x = switch(
      EXPR = attempt,
      first = x %>%
        group_by(user.id) %>%
        filter(attempt.number == min(attempt.number)),
      last =  x %>%
        group_by(user.id) %>%
        filter(attempt.number == max(attempt.number)),
      all = x,
      stop("Invalid attempt specification (use one of 'first', 'last', 'all' or a numeric vector", call. = FALSE)
    )
    return(x$attempt.id)
  }

  if (length(dplyr::setdiff(attempt, x$attempt.id)) > 0) {
    stop("These attempt IDs are not present: ",
         dplyr::setdiff(attempt, x$attempt.id),
         call. = FALSE)
  } else {
    return(attempt)
  }
}

#' Extract key
#'
#' Extract key
#' @param x Object of class \code{"mdl_quiz_data"}
#' @param distractors List of distractors for to get key for; if \code{NULL} (the default) all keys will be extracted
#' @export

extract_key.mdl_quiz_data = function(x, distractors = NULL) {

  if (is.null(distractors))
    distractors = names(x$distractors)

  all_keys = lapply(
    X = distractors,
    FUN = function(this_dist) {
      key_num = x$distractors[[this_dist]]$key %>%
        filter(answer.correct == 1) %>%
        select(question.id, answer.num)
      structure(
        .Data = key_num$answer.num,
        names = key_num$question.id
      )})

  unlist(all_keys)
}
