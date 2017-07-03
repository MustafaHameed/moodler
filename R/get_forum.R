#' Get Forum
#'
#' Fetches basic forum object.
#' @param conn DB connection
#' @param forum.id Forum ID (also in browser address bar)
#' @param prefix Database table prefix, defaults to \code{"mdl_"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @importFrom DBI dbGetQuery
#' @importFrom dplyr select_ bind_rows filter_
#' @importFrom stats setNames
#' @export

get_forum = function(conn, forum.id, prefix = "mdl_",
                     suppress.warnings = TRUE) {

  if (suppress.warnings) {

    settings = suppressWarnings(dbGetQuery(
      conn = .con,
      statement = use_query(
        module = "forum",
        query = "get_settings",
        prefix = prefix,
        forum.id = forum.id)))

  } else {

    settings = dbGetQuery(
      conn = .con,
      statement = use_query(
        module = "forum",
        query = "get_settings",
        prefix = prefix,
        forum.id = forum.id))

  }

  structure(
    list(settings, conn),
    names = c("settings", "connection"),
    class = "mdl_forum")

}
