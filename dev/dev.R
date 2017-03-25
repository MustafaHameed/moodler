# Make connection

library(DBI)
library(dplyr)

.con = dbConnect(RMySQL::MySQL(), group = "moodler")
dbGetQuery(.con, "SET NAMES utf8")
dbGetQuery(.con, "SET sql_mode = ''")

# Module data fetching ----
# =========================

q = get_quiz(.con, 73)
get_module_data(q, question.type = c("tre", "tri"))
get_module_data(q)
get_module_data(q, question.type = "truefalse")



# Question types ----
# ===================

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
  attempt.id = 2534:2435
)
