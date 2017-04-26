#' Test mdl_ objects
#'
#' These objects contain summary information about particular module instance.
#' @param x Object to be tested
#' @name is.mdl_

#' @export
#' @rdname is.mdl_
is.mdl_quiz = function(x)
  inherits(x, "mdl_quiz")

#' @export
#' @rdname is.mdl_
is.mdl_quiz_data = function(x)
  inherits(x, "mdl_quiz_data")

#' Get module data
#'
#' Fetch data for a specific module.
#' @param x An object of class \code{"mdl_"}, e.g. \code{"mdl_quiz"}
#' @param ... Further arguments passed on to methods
#' @export

get_module_data = function(x, ...)
  UseMethod("get_module_data")

#' Extract key
#'
#' Extract key (only when distractor data are available).
#' @param x An object of class \code{"mdl_quiz_data"}
#' @param question.type List of distractors for to get key for; if \code{NULL} (the default) all keys will be extracted
#' @param complete Should question name, text etc. be provided? Returns a \code{data.frame}
#' @export

extract_key = function(x, question.type = NULL, complete = FALSE)
  UseMethod("extract_key")

#' Extract item-level and distractor data
#'
#' Extract a matrix or data.frame of question marks
#'
#' Extract item marks either as binary (correct/incorrect) or categorical data (for multiplechoice questions). If the test contains a mixture of binary and categorical items (such as truefalse and multichoice), than \code{marks = "binary"} will collapse multiple choice items into correct/incorrect (1/0). When using \code{marks = "categorical"}, mutliplechoice options will be preserved but a key needs to be obtained (see for details). Raw percentages as they appear in Moodle can also be extracted by \code{marks = "moodle"}.
#' @param x An object of class \code{"mdl_quiz_data"}
#' @param marks Char, defaults to "categorical"
#' @param question.type List of distractors for to get key for; if \code{NULL} (the default) all keys will be extracted
#' @param fill What to use to fill missing values, defaults to \code{NA}
#' @param mat If \code{TRUE} (default), the result will be a \code{matrix} otherwise a \code{data.frame}
#' @importFrom dplyr %>% select left_join
#' @importFrom tidyr spread
#' @export

extract_items = function(x, marks = "categorical", question.type = NULL,
                         fill = NA, mat = TRUE)
  UseMethod("extract_items")
