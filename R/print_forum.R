#' Print moodle forum
#'
#' Print mdl_forum object.
#' @param x Object of class \code{"mdl_forum"}
#' @param ... further arguments passed to methods
#' @export

print.mdl_forum = function(x, ...) {

  cat(
    "\nForum: ", x$settings$forum.name,
    sep = "")

  cat(
    "\n\nforum id:    ", x$settings$forum.id,
    " [course id: ", x$settings$course.id, "]",
    "\nmodified:    ", as.character(x$settings$forum.timemodified),
    "\npost count:  ", x$settings$post.count,
    sep = "")
}

#' Print moodle forum data
#'
#' Print mdl_forum_data object.
#' @param x Object of class \code{"mdl_forum_data"}
#' @param ... further arguments passed to methods
#' @export

print.mdl_forum_data = function(x, ...) {

  cat(
    "\nForum: ", x$settings$forum.name,
    sep = "")

  cat(
    "\n\nforum id:    ", x$settings$forum.id,
    " [course id: ", x$settings$course.id, "]",
    "\nmodified:    ", as.character(x$settings$forum.timemodified),
    "\npost count:  ", x$settings$post.count,
    sep = "")

  # Calculate posts stats
  # Indiv. users, roles
  cat(
    "\n\nunique users:    ", length(unique(x$posts$user.id)),
    "\nmean word count: ", mean(x$posts$word.count, na.rm = TRUE),
    sep = "")
}
