# Make connection

library(DBI)
library(dplyr)

.con = dbConnect(RMySQL::MySQL(), group = "moodler")
dbGetQuery(.con, "SET NAMES utf8")

q74 = get_quiz(.con, 74)
get_truefalse(q74)
