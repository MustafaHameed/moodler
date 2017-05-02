SELECT

-- id/name/type
  cm.id AS 'forum.id',
  f.course AS 'course.id',
  f.name AS 'forum.name',
  f.type AS 'forum.type',
  
-- discussions/posts counts 
  (SELECT COUNT(fd.id)
    FROM [prefix]forum_discussions AS fd
    WHERE fd.forum = f.id) AS "discussion.count",
  (SELECT COUNT(fp.id) FROM [prefix]forum_posts AS fp
    JOIN [prefix]forum_discussions AS fd ON fd.id = fp.discussion
    WHERE f.id = fd.forum) AS "post.count",

-- grades and completion tracking
  f.assessed AS 'forum.assessed',  # Is this an assessed forum (0 = no, 1+ = yes )
  f.completionposts AS 'posts.required', # Certain number of posts is required to complete this activity.
  f.completionreplies AS 'replies.required',
  f.completiondiscussions AS 'discussions.required',

-- forum modified
	FROM_UNIXTIME(f.timemodified) AS 'forum.timemodified'
  
  
FROM [prefix]forum AS f
JOIN [prefix]course_modules AS cm
  ON f.course = cm.course AND f.id = cm.instance

WHERE cm.id IN ([module.id])

ORDER BY f.id, f.course, f.type;