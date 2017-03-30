# Make conn

# libs ----
library(DBI)
library(dplyr)
library(moodler)

# con ----
.con = dbConnect(RMySQL::MySQL(), group = "moodler")
dbGetQuery(.con, "SET NAMES utf8")
dbGetQuery(.con, "SET sql_mode = ''")
