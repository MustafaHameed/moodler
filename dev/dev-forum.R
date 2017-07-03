# DEV forums

# setup ----
# ==========

library(moodler)
library(DBI)

source("dev/conn.R")
prefix = "mdl_"
forum.id = 178

# Fetch settings ----
# ===================

crs = get_courses(.con) #the forum course id = 6
mdl = get_course_modules(.con, 6, module.type = "forum") #eg module.id = 175

qry = use_query("forum", "get_settings", prefix = "mdl_", forum.id = 175:180)
cat(qry)

dbGetQuery(
  conn = .con,
  statement = use_query(
    module = "forum",
    query = "get_settings",
    prefix = prefix,
    forum.id = forum.id))
