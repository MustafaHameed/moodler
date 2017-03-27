#' Print moodle quiz
#'
#' Print mdl_quiz object.
#' @param x Object of class \code{"mdl_quiz"}
#' @param ... further arguments passed to methods
#' @export

print.mdl_quiz = function(x, ...) {

  cat(
    "\nQuiz: ", x$settings$quiz.name,
    sep = "")

  cat(
    "\n\nquiz id:    ", x$settings$quiz.id,
    " [course id: ", x$settings$course.id, "]",
    "\nmodified:   ", as.character(x$settings$quiztimemodified),
    sep = "")

  cat(
    "\nmax points: ", x$settings$sumgrades,
    "\nmax grade:  ", x$settings$grade,
    sep = "")

  if (!is.null(x$attempts)) {
    mean_min = mean(x$attempts$attempt.time.taken, na.rm = TRUE)
    cat(
      "\nattempts:   ",
      x$settings$attemptscount,
      " [", length(unique(x$attempts$user.id)),
      " users, mean duration ", round(mean_min, 1), " min]",
      sep = ""
    )
  } else {
    cat("\nattempts:   0")
  }

  cat(
    "\n\n",
    length(unique(x$questions$question.id)), " items on ",
    max(x$questions$page.number), " pages:\n\n",  sep = ""
  )

  item_count = structure(
    as.data.frame(table(x$questions$question.type)),
    names = c("item.type", "count"))

  print(item_count, ...)
}

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
                                    prefix = "mdl_",
                                    suppress.warnings = TRUE,
                                    ...) {

  if (!nrow(x$attempts)) {
    message("No attempts: aborted")
    return()
  }

  stopifnot(any(is.character(attempt), is.numeric(attempt)))

  if (is.character(attempt)) {
    attempt_id = get_attempt_id(
      x = x$attempts,
      attempt = attempt)
  }

  if (is.numeric(attempt)) {
    attempt_id = dplyr::intersect(
      x = attempt,
      y = x$attempts$attempt.id)
    if (length(attempt_id) > 0) {
      message("Fetching attempts:\n", paste(attempt_id, collapse = " "))
    } else {
      stop("No such attempt", call. = FALSE)
    }
  }

  if (is.null(question.type)) {
    question_type = unique(x$questions$question.type)
  } else {
    question_type = dplyr::intersect(
      x = question.type,
      y = x$questions$question.type)
    if (length(question_type) > 0) {
      message(
        "Fetching question types:\n",
        paste(question_type, collapse = " "))
    } else {
      stop("No such question", call. = FALSE)
    }
  }

  dat = lapply(
    X = question_type,
    FUN = function(this_type) {
      this_fun = paste0("get_", this_type)
      if (exists(x = this_fun, mode = "function")) {
        message("Fething: ", this_type)
        do.call(
          what = this_fun,
          args = list(
            conn = x$connection,
            quiz.id = x$settings$quiz.id,
            attempt.id = attempt_id,
            prefix = prefix,
            suppress.warnings = suppress.warnings))
      }
    })

  names(dat) = question_type
  dat[!sapply(dat, is.null)]
}

get_attempt_id = function(x, attempt = "first") {

  x = switch(
    EXPR = attempt,
    first = x %>%
      group_by(user.id) %>%
      filter(attempt.number == min(attempt.number)),
    last =  x %>%
      group_by(user.id) %>%
      filter(attempt.number == max(attempt.number)),
    all = x,
    message("Invalid attempt specification; using 'all'")
  )

  x$attempt.id
}
