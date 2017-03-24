SELECT

  -- Quiz related
  q.course AS 'course.id',
  cm.id AS 'quiz.id',
  q.name AS 'quiz.name',
  q.sumgrades AS 'quiz.maxpoints',
  q.grade AS 'quiz.maxgrade',

  -- User related
  u.id AS 'u.id',
  u.email AS 'u.email',
  CONCAT(u.lastname, ', ', u.firstname) AS 'u.name',

  -- Attempt related
  quiza.id AS 'attempt.id',
  quiza.attempt AS 'attempt.number',
  quiza.state AS 'attempt.state',
  FROM_UNIXTIME(quiza.timestart) AS 'attempt.start',
  FROM_UNIXTIME(quiza.timefinish) AS 'attempt.finish',
  TIMEDIFF(FROM_UNIXTIME(quiza.timefinish),
      FROM_UNIXTIME(quiza.timestart)) AS 'attempt.time.taken',
  quiza.layout AS 'attempt.layout',
  quiza.sumgrades AS 'attempt.points'

FROM [prefix]quiz AS q
JOIN [prefix]course_modules AS cm
  ON q.course = cm.course AND q.id = cm.instance
JOIN [prefix]quiz_attempts AS quiza
  ON q.id = quiza.quiz
JOIN [prefix]user AS u
  ON quiza.userid = u.id

WHERE quiza.preview = 0 AND
      quiza.state IN ([attempt.state]) AND # 'abandoned', 'finished', 'inprogress'
	  cm.id IN ([module.id])

ORDER BY quiza.userid, quiza.attempt;
