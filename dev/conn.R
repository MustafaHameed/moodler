# Make conn

# libs ----
library(DBI)
library(dplyr)
library(moodler)

# con ----
.con = dbConnect(RMySQL::MySQL(),
                 password = "moodler",
                 username = "moodler",
                 dbname = "moodle",
                 host = "127.0.0.1")

dbGetQuery(.con, "SET NAMES utf8")
dbGetQuery(.con, "SET sql_mode = ''")

# # create new user (if need be) ----
# qry1 = "CREATE USER 'moodler'@'localhost' IDENTIFIED BY 'moodler';"
# dbGetQuery(.con, qry1)
#
# qry2 = "GRANT ALL PRIVILEGES ON * . * TO 'moodler'@'localhost';"
# dbGetQuery(.con, qry2)
