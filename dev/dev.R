# Make connection

library(DBI)
library(dplyr)

.con = dbConnect(RMySQL::MySQL(), group = "moodler")
dbGetQuery(.con, "SET NAMES utf8")
dbGetQuery(.con, "SET sql_mode = ''")

q74 = get_quiz(.con, 74)
tf = moodler:::get_truefalse(q74, attempt.id = c(2514, 2533))

q79 = get_quiz(.con, 79)
sa = moodler:::get_shortanswer(q79, attempt.id = 2534:2435)
