SELECT

-- Forum related

  cm.id AS 'forum.id',
  f.course AS 'course.id',
  f.type AS 'forum.type',
  
-- Discussion related
  p.discussion AS 'discussion.id',  

-- Post related
  p.id AS 'post.id',
  p.parent AS 'parent.post',  # 0 = this is the first post in this discussion
  FROM_UNIXTIME(p.created) AS 'post.created',
  FROM_UNIXTIME(p.modified) AS 'post.modified',
  p.subject AS 'post.subject',
  p.message AS 'post.text',
  CASE p.attachment WHEN ''
    THEN '0'
	ELSE p.attachment
  END AS 'attachments.count',
  
-- user related  
  p.userid AS 'user.id',
  (SELECT CONCAT(u.lastname, ', ', u.firstname) FROM [prefix]user AS u
    WHERE p.userid = u.id) AS 'user.name',
  (SELECT r.shortname FROM [prefix]role_assignments AS ra
    JOIN [prefix]context AS c ON ra.contextid = c.id
    JOIN [prefix]role AS r ON ra.roleid = r.id
    WHERE ra.userid = p.userid AND c.instanceid = f.course) AS 'user.role'
    # Zatím zřejmě jen provizorní řešení. Je třeba ještě podrobněji otestovat.
    # Momentálně v některých případech vyhazuje NULL. je třeba ověřit, jestli je to skutečně jen v případech,
    # kdy uživatel v kurzu nikdy nebyl zapsán/neměl přidělenou roli (spíše to vypadá, že ne).
  
FROM [prefix]forum AS f
JOIN [prefix]course_modules AS cm
  ON f.course = cm.course AND f.id = cm.instance
JOIN [prefix]forum_discussions AS d ON f.id= d.forum
JOIN [prefix]forum_posts AS p ON d.id = p.discussion

WHERE cm.id IN ([module.id])

ORDER BY f.course, f.id, f.type, p.discussion;