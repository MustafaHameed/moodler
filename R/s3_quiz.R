#' Get Quiz Data
#'
#' Fetch item data from a quiz.
#' @param x An object of class \code{"mdl_quiz"}
#' @param attempt Defaults to \code{"first"}; \code{"all"} and \code{"last"} are also allowed, or a numeric vector specifying attempt IDs
#' @param question.type Char vector, if \code{NULL}, all items regardless of type will be fetched
#' @param distractors List of distractors for to get key for; if \code{NULL} (the default) all keys will be extracted
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
    select(attempt.id, question.type, question.id, question.name, question.text,
           question.maxpoints, page.number, slot.number, answer.time,
           answer.percent)

  if (!distractors)
    return(
      structure(
        .Data = list(
          settings = x$settings,
          attempts = x$attempts,
          items = items_tidy),
        class = "mdl_quiz_data")
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
#' @param question.type List of distractors for to get key for; if \code{NULL} (the default) all keys will be extracted
#' @param complete Should question name, text etc. be provided? Returns a \code{data.frame}
#' @importFrom dplyr %>% filter select if_else
#' @export

quiz_key.mdl_quiz_data = function(x, question.type = NULL,
                                     complete = FALSE) {

  if (is.null(question.type))
    question.type = names(x$distractors)
  else
    stopifnot(all(question.type %in% names(x$distractors)))

  if (complete) {
    keys_li = lapply(
      X = question.type, FUN = function(this_dist) {
        x$distractors[[this_dist]]$key})
    keys_df = do.call("rbind", keys_li)
    keys = keys_df %>%
      mutate(
        answer.text = if_else(
          answer.correct == 1,
          paste("*", answer.text, sep = ""),
          answer.text))
    return(keys)
  }

  keys = lapply(
    X = question.type,
    FUN = function(this_dist) {
      key_num = x$distractors[[this_dist]]$key %>%
        filter(answer.correct == 1) %>%
        select(question.id, answer.num)
      structure(
        .Data = key_num$answer.num,
        names = key_num$question.id
      )})

  unlist(keys)
}

#' Extract item-level and distractor data
#'
#' Extract a matrix or data.frame of question marks
#'
#' Extract item marks either as binary (correct/incorrect) or categorical data (for multiplechoice questions). If the test contains a mixture of binary and categorical items (such as truefalse and multichoice), than \code{marks = "binary"} will collapse multiple choice items into correct/incorrect (1/0). When using \code{marks = "categorical"}, mutliplechoice options will be preserved but a key needs to be obtained (see \code{\link{quiz_key}} for details). Weighted percentages can also be extracted by \code{marks = "weighted"} - in this case, each item's contribution will be weighted by its nominal weight, set in the quiz edit page in Moodle. Finally, you can obtain nominal weights as they appear on the edit quiz page, using \code{marks = "nominal"}.
#' @param x An object of class \code{"mdl_quiz_data"}
#' @param marks Char, defaults to "categorical"
#' @param question.type List of distractors for to get key for; if \code{NULL} (the default) all keys will be extracted
#' @param fill What to use to fill missing values, defaults to \code{NA}
#' @param mat If \code{TRUE} (default), the result will be a \code{matrix} otherwise a \code{data.frame}
#' @importFrom dplyr %>% select left_join
#' @importFrom tidyr spread
#' @export

quiz_items.mdl_quiz_data = function(x, marks = "categorical",
                                       question.type = NULL, fill = NA,
                                       mat = TRUE) {

  stopifnot(marks %in% c("categorical", "binary", "percent", "weighted",
                         "nominal"))

  marks_df = switch(
    marks,
    categorical = spread_cat(
      dist_data = x$distractors,
      question.type = question.type,
      fill = fill
    ),
    binary = spread_bin(
      dist_data = x$distractors,
      question.type = question.type,
      fill = fill
    ),
    percent = spread_perc(
      item_data = x$items,
      fill = fill
    ),
    weighted = spread_weighted(
      item_data = x$items,
      fill = fill
    ),
    nominal = spread_nominal(
      item_data = x$items,
      fill = fill
    )
  )

  if (mat) {
    rownames(marks_df) = marks_df$attempt.id
    as.matrix(marks_df[-1])
  } else {
    marks_df
  }
}

spread_weighted = function(item_data, fill = NA) {

  item_data %>%
    mutate(answer.points = answer.percent * question.maxpoints,
           answer.percent = answer.points / max(question.maxpoints)) %>%
    select(attempt.id, question.id, answer.percent) %>%
    spread(
      key = question.id,
      value = answer.percent,
      convert = TRUE,
      fill = fill)
}

spread_nominal = function(item_data, fill = NA) {

  item_data %>%
    mutate(answer.points = answer.percent * question.maxpoints) %>%
    select(attempt.id, question.id, answer.points) %>%
    spread(
      key = question.id,
      value = answer.points,
      convert = TRUE,
      fill = fill)
}

spread_perc = function(item_data, fill = NA) {

  item_data %>%
    select(attempt.id, question.id, answer.percent) %>%
    spread(
      key = question.id,
      value = answer.percent,
      convert = TRUE,
      fill = fill)
}

spread_cat = function(dist_data, question.type = NULL,
                      fill = NA) {

  stopifnot(all(question.type %in% names(dist_data)))

  if (is.null(question.type))
    question.type = names(dist_data)
  else
    stopifnot(all(question.type %in% names(dist_data)))

  marks_list = lapply(
    X = question.type, FUN = function(this_type) {
    dist_data[[this_type]]$ans %>%
      select(attempt.id, question.id, answer.num) %>%
      spread(
        key = question.id,
        value = answer.num,
        convert = TRUE,
        fill = fill)
  })

  suppressMessages(
    as.data.frame(Reduce(left_join, marks_list))
  )
}

spread_bin = function(dist_data, question.type = NULL, fill = NA) {

  stopifnot(all(question.type %in% names(dist_data)))

  if (is.null(question.type))
    question.type = names(dist_data)
  else
    stopifnot(all(question.type %in% names(dist_data)))

  marks_list = lapply(
    X = question.type, FUN = function(this_type) {
      this_ans = select(dist_data[[this_type]]$ans,
                        attempt.id, question.id, answer.num)
      this_key = select(dist_data[[this_type]]$key,
                        question.id, answer.num, answer.correct)
      left_join(this_ans, this_key, by = c("question.id", "answer.num")) %>%
        select(-answer.num) %>%
        spread(
          key = question.id,
          value = answer.correct,
          convert = TRUE,
          fill = fill)
    })

  suppressMessages(
    as.data.frame(Reduce(left_join, marks_list))
  )
}

#' Extract whole-quiz scores
#'
#' Extract whole-quiz scores for each attempt.
#'
#' See \code{\link{quiz_items}} on how the item marks can be specified.
#' @param x An object of class \code{"mdl_quiz_data"}
#' @param marks How items should be graded; see \code{\link{quiz_items}} for details
#' @export

quiz_scores.mdl_quiz_data = function(x, marks = "binary") {

  if (marks == "categorical") {
    warning("Don't know how to use categorical marks - using binary instead")
    marks = "binary"
  }

  items = quiz_items(x, marks = marks, mat = FALSE)
  items %>% mutate(score = rowSums(.[, -1], na.rm = TRUE)) %>%
    select(attempt.id, score)
}

# tercile = function(x, labels = c("lower", "middle", "upper")) {
#   q3 = unique(quantile(x, probs = c(1/3, 2/3)))
#   if (length(q3) == 2)
#     cut(x, breaks = c(-Inf, q3, Inf), labels = labels)
#   else
#     cut(x, breaks = c(-Inf, q3, Inf), labels = labels[c(1, 3)])
# }
