SELECT

  -- Quiz related
  q.id AS 'quiz.id',
  cm.id AS 'quiz.cmid',
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

FROM mdl_quiz AS q
JOIN mdl_course_modules AS cm
  ON q.course = cm.course AND q.id = cm.instance
JOIN mdl_quiz_attempts AS quiza
  ON q.id = quiza.quiz
JOIN mdl_user AS u
  ON quiza.userid = u.id

WHERE quiza.preview = 0 AND 
      quiza.state = '[attempt.state]' AND   # vybírá se vždy jen jeden stav, příp. lze udělat přes IN jako níže pro výběr více stavů
      q.course IN ([course.id]) AND 
	  cm.id IN ([module.id])

ORDER BY quiza.userid, quiza.attempt;
