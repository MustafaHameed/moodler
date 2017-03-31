# Module data fetching ----
# =========================

q = get_quiz(.con, 73)
get_module_data(q, question.type = c("tre", "tri"))
get_module_data(q)
get_module_data(q, question.type = "truefalse")

q = get_quiz(.con, 78)
mc1 = get_module_data(q, question.type = "multichoice_one")
mc1 = get_module_data(q, attempt = c(2536, 2531, 1))
mc1 = get_module_data(q, attempt = 0)

mc0 = get_module_data(q, question.type = "multichoice_multiple")


# TF, SA ----
# ===========

q = get_quiz(.con, 74)
tf = moodler:::get_truefalse(
  conn = q$connection,
  quiz.id = q$settings$quiz.id,
  attempt.id = c(2514, 2533)
)

q = get_quiz(.con, 79)
sa = moodler:::get_shortanswer(
  conn = q$connection,
  quiz.id = q$settings$quiz.id,
  attempt.id = 2534:2535
)

# MC 1 ----
# =========

source("dev/conn.R")
q = get_quiz(.con, 80)
mc1 = moodler:::get_multichoice_one(
  conn = q$connection,
  attempt.id = q$attempts$attempt.id
)

# MC 0 ----
# =========

source("dev/conn.R")
q = get_quiz(.con, 80)
mc0 = moodler:::get_multichoice_multiple(
  conn = q$connection,
  quiz.id = q$settings$quiz.id,
  attempt.id = q$attempts$attempt.id
)

