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
    "\n\ncreated:    ", x$settings$quiztimecreated,
    " [id: ", x$settings$quiz.id, ", course id: ", x$settings$course.id, "]",
    "\nmodified:   ", x$settings$quiztimemodified,
    sep = "")

  cat(
    "\nmax points: ", x$settings$sumgrades,
    "\nmax grade:  ", x$settings$grade,
    sep = "")

  if (!is.null(x$attempts)) {
    time_taken = as.difftime(x$attempts$attempt.time.taken, units = "mins")
    mean_min = mean(time_taken, na.rm = TRUE)
    cat(
      "\nattempts:   ",
      x$settings$attemptscount,
      " [", length(unique(x$attempts$u.id)),
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
#' @param attempt Defaults to \code{"first"} but \code{"all"} and \code{"last"} are also allowed
#' @param question.type Char vector, if \code{NULL}, all items regardless of type will be fetched
#' @param prefix Defaults to \code{"mdl_"}
#' @param ... Further arguments passed on to methods
#' @export

get_module_data.mdl_quiz = function(x, attempt = "first",
                                    question.type = NULL,
                                    prefix = "mdl_",
                                    ...) {

  attempt_id = get_attempt_id(x = x$attempts, attempt = attempt)
  available_types = unique(x$questions$question.type)

  if (!is.null(question.type)) {
    if (!all(question.type %in% available_types)) {
      missing_type = paste(
        question.type[!question.type %in% available_types],
        collapse = ", ")
      stop(missing_type, " not available in this quiz", call. = FALSE)
    }
  }

  dat = lapply(available_types, function(this_type) {
    fun_name = paste0("get_", this_type)
    c(tryCatch(
      expr = do.call(
        what = fun_name,
        args = list(conn = x$connection,
                    quiz.id = x$settings$quiz.id,
                    attempt.id = attempt_id,
                    prefix = prefix)),
      error = function(e)
        message(e$message)
      ))
  })

  structure(dat, names = available_types)
}

get_attempt_id = function(x, attempt = "first") {

  stopifnot(attempt %in% c("first", "all", "last"))

  attempt_number = list(
    first = "attempt.number == min(attempt.number)",
    all = "is.integer(attempt.number)",
    last = "attempt.number == max(attempt.number)")

  attempt = attempt_number[[attempt]]

  x %>%
    group_by(u.id) %>%
    filter_(.dots = attempt) %>%
    `[[`("attempt.id")
}
