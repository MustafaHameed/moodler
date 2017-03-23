#' Get Courses
#'
#' Get course names, ids, basic info.
#' @param conn DB connection
#' @param prefix Database table prefix, defaults to \code{"mdl_"}
#' @importFrom DBI dbGetQuery
#' @export

get_courses = function(conn, prefix = "mdl_") {
  dbGetQuery(
    conn = conn,
    statement = use_query(
      module = "general", query = "get_courses", prefix = prefix)
    )
}

#' Get Course Modules
#'
#' Get a list of modules within given course(s).
#' @param conn DB connection
#' @param course.id Vector of course IDs
#' @param module.names Should module names be also fetched (slower)? Defaults to \code{TRUE}
#' @param module.type What modules should be listed? By default, all are fetched
#' @param prefix Database table prefix, defaults to \code{"mdl_"}
#' @importFrom DBI dbGetQuery
#' @export

get_course_modules = function(conn, course.id, module.names = TRUE,
                              module.type = NULL, prefix = "mdl_") {

  course_modules = dbGetQuery(
    conn = conn,
    statement = use_query(
      module = "general",
      query = "get_course_modules",
      prefix = prefix,
      course.id = course.id)
  )

  if (!is.null(module.type)) {
    stopifnot(is.character(module.type))
    required_types = course_modules$module.type %in% module.type
    course_modules = course_modules[required_types, ]
  }

  if (!module.names)
    return(course_modules)

  course_id = unique(course_modules$course.id)
  module_type = unique(course_modules$module.type)

  module_names = lapply(
    X = module_type,
    FUN = function(this_type) {
      dbGetQuery(
        conn = conn,
        statement = use_query(
          module = "general",
          query = "get_module_name",
          prefix = prefix,
          course.id = course_id,
          module.type = this_type)
      )
    }
  )

  merge(
    x = course_modules,
    y = do.call("rbind", module_names)
  )
}
