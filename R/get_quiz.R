#' Get Quiz
#'
#' Fetches basic quiz object.
#' @param conn DB connection
#' @param quiz.id Quiz ID (also in browser address bar)
#' @param attempt.state Defaults to \code{"finished"}
#' @param prefix Database table prefix, defaults to \code{"mdl_"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @importFrom DBI dbGetQuery
#' @export

get_quiz = function(conn, quiz.id, attempt.state = "finished",
                    prefix = "mdl_",
                    suppress.warnings = TRUE) {

  stopifnot(all(attempt.state %in% c("abandoned", "finished", "inprogress")))

  if (suppress.warnings) {

    settings = suppressWarnings(dbGetQuery(
      conn = conn,
      statement = use_query(
        module = "quiz",
        query = "get_settings",
        prefix = prefix,
        module.id = quiz.id)))

    attempts = suppressWarnings(dbGetQuery(
        conn = conn,
        statement = use_query(
          module = "quiz",
          query = "get_attempts",
          prefix = prefix,
          module.id = quiz.id,
          attempt.state = attempt.state)))

    questions = suppressWarnings(dbGetQuery(
        conn = conn,
        statement = use_query(
          module = "quiz",
          query = "get_questions",
          prefix = prefix,
          module.id = quiz.id)))

  } else {

    settings = dbGetQuery(
      conn = conn,
      statement = use_query(
        module = "quiz",
        query = "get_settings",
        prefix = prefix,
        module.id = quiz.id))

    attempts = dbGetQuery(
      conn = conn,
      statement = use_query(
        module = "quiz",
        query = "get_attempts",
        prefix = prefix,
        module.id = quiz.id,
        attempt.state = attempt.state))

    questions = dbGetQuery(
      conn = conn,
      statement = use_query(
        module = "quiz",
        query = "get_questions",
        prefix = prefix,
        module.id = quiz.id))
  }

  settings$quiztimemodified = as.POSIXct(settings$quiztimemodified)
  attempts$attempt.start = as.POSIXct(attempts$attempt.start)
  attempts$attempt.finish = as.POSIXct(attempts$attempt.finish)
  attempts$attempt.time.taken = as.difftime(attempts$attempt.time.taken,
                                            units = "min")
  questions$question.text = remove_tags(questions$question.text)

  unique_quiz_id = as.character(unique(settings$quiz.id))

  if (length(unique_quiz_id) > 1) {

    list_settings = split(settings, settings$quiz.id)
    list_attempts = split(attempts, attempts$quiz.id)
    list_questions = split(questions, questions$quiz.id)

    structure(
      lapply(
        X = unique_quiz_id,
        FUN = function(this_id)
          structure(
            list(list_settings[[this_id]],
                 list_attempts[[this_id]],
                 list_questions[[this_id]],
                 conn),
            names = c("settings", "attempts", "questions", "connection"),
            class = "mdl_quiz")
      ),
      names = unique_quiz_id
    )

  } else {

    structure(
      list(settings, attempts, questions, conn),
      names = c("settings", "attempts", "questions", "connection"),
      class = "mdl_quiz")
  }
}
