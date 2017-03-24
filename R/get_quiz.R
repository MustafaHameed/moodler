#' Get Quiz
#'
#' Fetches basic quiz object.
#' @param conn DB connection
#' @param quiz.id Quiz ID (also in browser address bar)
#' @param attempt.state Defaults to \code{"finished"}
#' @param prefix Database table prefix, defaults to \code{"mdl_"}
#' @importFrom DBI dbGetQuery
#' @export

get_quiz = function(conn, quiz.id, attempt.state = "finished",
                    prefix = "mdl_") {

  stopifnot(all(attempt.state %in% c("abandoned", "finished", "inprogress")))

  settings = dbGetQuery(
    conn = conn,
    statement = use_query(
      module = "quiz",
      query = "get_settings",
      prefix = prefix,
      module.id = quiz.id
    )
  )

  attempts = dbGetQuery(
    conn = conn,
    statement = use_query(
      module = "quiz",
      query = "get_attempts",
      prefix = prefix,
      module.id = quiz.id,
      attempt.state = attempt.state
    )
  )

  questions = dbGetQuery(
    conn = conn,
    statement = use_query(
      module = "quiz",
      query = "get_questions",
      prefix = prefix,
      module.id = quiz.id
    )
  )

  # Unique quiz ID
  quiz_id_u = as.character(unique(settings$quiz.id))

  if (length(quiz_id_u) > 1) {

    list_settings = split(settings, settings$quiz.id)
    list_attempts = split(attempts, attempts$quiz.id)
    list_questions = split(questions, questions$quiz.id)

    structure(
      lapply(
        X = quiz_id_u,
        FUN = function(this_id)
          structure(
            list(list_settings[[this_id]],
                 list_attempts[[this_id]],
                 list_questions[[this_id]]),
            names = c("settings", "attempts", "questions"),
            class = "mdl_quiz")
      ),
      names = quiz_id_u
    )

  } else {

    structure(
      list(settings, attempts, questions),
      names = c("settings", "attempts", "questions"),
      class = "mdl_quiz")
  }
}
