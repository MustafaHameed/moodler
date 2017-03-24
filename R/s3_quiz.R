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

  print(item_count)
}
