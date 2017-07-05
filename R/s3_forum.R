#' Get Forum Data
#'
#' Fetch posts and related forum data.
#' @param x An object of class \code{"mdl_forum"}
#' @param prefix Defaults to \code{"mdl_"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @param ... Further arguments passed on to methods
#' @importFrom tidyr gather
#' @importFrom dplyr select filter mutate
#' @export

get_module_data.mdl_forum = function(x, prefix = "mdl_",
                                     suppress.warnings = TRUE,
                                     ...) {

  posts = dbGetQuery(
    conn = .con,
    statement = use_query(
      module = "forum",
      query = "get_forum_posts",
      prefix = prefix,
      forum.id = x$settings$forum.id
    )
  )

  posts_long = posts %>%
    gather(
      key = "key",
      value = "role",
      -c(forum.id:user.name)) %>%
    select(-key)

  posts_roles = posts_long %>%
    filter(!is.na(role)) %>%
    mutate(role = recode(
      role,
      editingteacher = 5, teacher = 4, student = 3,
      role.other1 = 2, role.other2 = 1))

  posts_clean = posts_roles %>%
    mutate(
      attachments.count = as.numeric(attachments.count),
      post.text = untag(post.text),
      word.count = word_count(post.text))

  structure(
    .Data = list(
      settings = x$settings,
      posts = posts_clean
    ),
    class = "mdl_forum_data"
  )
}

#' Create a nodelist
#'
#' Create a nodelist.
#' @param x An object of class \code{"mdl_forum_data"}
#' @param prefix Defaults to \code{"mdl_"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @param ... Further arguments passed on to methods
#' @importFrom dplyr select group_by summarise %>%
#' @export

extract_nodes.mdl_forum_data = function(x, ...) {
  x = x$posts
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

#' Create an edgelist
#'
#' Create an edgelist.
#' @param x An object of class \code{"mdl_forum_data"}
#' @param prefix Defaults to \code{"mdl_"}
#' @param suppress.warnings Should warnings produced by \code{\link[DBI]{dbGetQuery}} be suppressed? Defaults to \code{TRUE}
#' @param ... Further arguments passed on to methods
#' @importFrom dplyr select count
#' @export

extract_edges.mdl_forum_data = function(x, ...) {
  x = x$posts
  edge_child = select(x, id = post.id, target = user.id)
  edge_parent = select(x, id = parent.post, source = user.id)
  edge_both = merge(edge_parent, edge_child, by = "id")
  count(edge_both, source, target)
}
