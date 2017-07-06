# DEV forums

# setup ----
# ==========

library(moodler)
library(DBI)

source("dev/conn.R")
prefix = "mdl_"
forum.id = 178

# Explore DB ----
# ===============

crs = get_courses(.con) #the forum course id = 6
mdl = get_course_modules(.con, 6, module.type = "forum") #eg module.id = 175

# Fetch posts ----
# ================

f = get_forum(.con, 178)
p = get_module_data(f)

# Prepare for plotting: edges and nodes ----
# ==========================================

edges = extract_edges(p)
nodes = extract_nodes(p)


