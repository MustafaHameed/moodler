#' Test mdl_ objects
#'
#' These objects contain summary information about particular module instance.
#' @param x Object to be tested
#' @name is.mdl_

#' @export
#' @rdname is.mdl_
is.mdl_quiz = function(x)
  inherits(x, "mdl_quiz")
