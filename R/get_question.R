# Get question

#' Has every question been answered?
#'
#' Questions that are missing will be replaced by NA records.
#' @param key Data from get_[question type]_key query
#' @param ans Data from get_[question type]_ans query
#' @importFrom dplyr %>% select starts_with left_join

has_answered = function(key, ans) {

  questions = key %>%
    select(-starts_with("answer")) %>%
    unique()

  attempts = ans %>%
    select(user.id, attempt.id) %>%
    unique()

  # Get all combinations of attempt x question
  att_que =
    expand.grid(
      attempt.id = unique(ans$attempt.id),
      question.id = unique(key$question.id)
    )

  att_que %>%
    left_join(questions, by = "question.id") %>%
    left_join(attempts, by = "attempt.id")
}
