# Print mdl_quiz & mdl_quiz_data

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

#' Print moodle quiz data
#'
#' Print mdl_quiz object.
#' @param x Object of class \code{"mdl_quiz"}
#' @param ... further arguments passed to methods
#' @export

print.mdl_quiz_data = function(x, ...) {

  cat(
    "\nQuiz: ", x$settings$quiz.name,
    sep = "")

  cat(
    "\n\nquiz id:    ", x$settings$quiz.id,
    " [course id: ", x$settings$course.id, "]",
    "\nmodified:   ", as.character(x$settings$quiztimemodified),
    sep = "")

  cat("\n\nItem-level data:\n\n")
  item_level = structure(
    .Data = as.data.frame(table(x$items$question.type)),
    names = c("item.type", "count")
  )

  print(item_level)

  if (is.null(x$distractors)) {

    cat("\nDistractor data [NONE]")

  } else {

    distractor_list = lapply(
      x$distractors, function(y)
        length(unique(y$ans$question.id)))

    distractor = data.frame(
      item.type = names(distractor_list),
      count = unlist(distractor_list),
      row.names = NULL,
      stringsAsFactors = FALSE
    )

    cat("\nDistractor data:\n\n")

    print(distractor)
  }
}
