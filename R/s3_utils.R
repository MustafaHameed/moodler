#' Test mdl_ objects
#'
#' These objects contain summary information about particular module instance.
#' @param x Object to be tested
#' @name is.mdl_

#' @export
#' @rdname is.mdl_
is.mdl_quiz = function(x)
  inherits(x, "mdl_quiz")

#' Get module data
#'
#' Fetch data for a specific module.
#' @param x An object of class \code{"mdl_"}, e.g. \code{"mdl_quiz"}
#' @param ... Further arguments passed on to methods
#' @export

get_module_data = function(x, ...)
  UseMethod("get_module_data")
