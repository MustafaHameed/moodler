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

# Fetch posts ----
# ================

f = get_forum(.con, 178)
p = get_module_data(f)
save(p, file = "dev/p.RData")

# Prepare for plotting: edges and nodes ----
# ==========================================

get_edges = function(x) {
  edge_child = select(x, id = post.id, target = user.id)
  edge_parent = select(x, id = parent.post, source = user.id)
  edge_both = merge(edge_parent, edge_child, by = "id")
  count(edge_both, source, target)
}

get_nodes = function(x) {
  node_bare = x %>%
    select(user.id, user.name, role) %>%
    unique()
  node_summ = x %>%
    group_by(user.id) %>%
    summarise(
      post.n = n(),
      attachment.n = sum(attachments.count),
      word.count = sum(word.count),
      word.mean = mean(word.count))
  merge(node_bare, node_summ, by = "user.id")
}

edgelist = get_edges(p$posts)
nodelist = get_nodes(p$posts)
