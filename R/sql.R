#' Load SQL Query
#'
#' Load SQL query template and replace given fields with values.
#' @param module Which module
#' @param query Query
#' @param prefix Defaults to \code{"mdl_"}
#' @param ... Further arguments to match sql query fields
#' @export

use_query = function(module, query, prefix = "mdl_", ...) {
  sql = load_sql(module = module, query = query)
  insert_values(query = sql$query, fields = sql$fields, prefix = prefix, ...)
}

# Insert values (sql.fields) into an SQL query (sql.text)
insert_values = function(query, fields, prefix, ...) {

  dots = c(list(...), prefix = prefix)

  if (!all(names(dots) %in% fields))
    warning(
      "Field not present: ",
      paste(names(dots)[!names(dots) %in% fields], collapse = " "),
      call. = FALSE)

  if (!all(fields %in% names(dots)))
    stop(
      "Please specify: ",
      paste(fields[!fields %in% names(dots)], collapse = " "),
      call. = FALSE)

  for (this_name in names(dots))
    query = gsub(
      pattern = paste0("\\[", this_name, "\\]"),
      replacement = paste_sql(x = dots[[this_name]], x.name = this_name),
      x = query)

  query
}

# Paste values
paste_sql = function(x, x.name) {
  if (any(is.numeric(x), is.double(x)))
    paste(x, collapse = ",")
  else if (x.name %in% c("prefix", "module.type"))
    x
  else
    paste(paste("'", x, "'", sep = ""), collapse = ",")
}

# Load query from /inst
load_sql = function(module, query) {
  sql_path = paste0(module, "/", query, ".sql")
  sql_file = system.file("sql", sql_path, package="moodler")
  sql_text = suppressWarnings(
    paste(readLines(sql_file), collapse = "\n")
  )
  list(
    query = sql_text,
    fields = gsub(
      pattern = "(\\[|\\])", replacement = "",
      x = reg_match(sql_text, "\\[[^\\[]+\\]"))
  )
}
