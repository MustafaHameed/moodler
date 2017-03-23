SELECT

  -- id/name
  cm.id AS 'quiz.cmid',
  q.name AS 'quiz.name',

  -- Attempt count
    (SELECT COUNT(qa.id) FROM [prefix]quiz_attempts AS qa
		WHERE q.id = qa.quiz GROUP BY qa.quiz) AS 'attemptscount',

  -- Random question order?
    (SELECT SUM(qsec.shufflequestions) FROM [prefix]quiz_sections AS qsec
		WHERE q.id = qsec.quizid) AS 'shufflequestions',

	q.shuffleanswers,      # Shuffle within question
	q.navmethod,           # Navigation method
	q.preferredbehaviour,  # Question behavior
	q.canredoquestions,    # Allow redo within an attempt (depends on question behavior)
    q.attemptonlast,       # Each attempt builds on the last (1 = yes, 0 = no)

  -- Time & attempt limits
    q.timeopen,      # Quiz opened
	q.timeclose,     # Quiz closed (quiz closed - quiz opened = time available)
	q.timelimit,     #
    q.attempts,      # Attempts alowed
	q.delay1,        # Enforced delay between 1st and 2nd attempts
	q.delay2,        # Enforced delay between later attempts

  -- Grades
	q.grademethod,                  # Grading method (for more than one attempt)
    q.completionattemptsexhausted,  # Completion tracking: All available attempts completed
	q.completionpass,               # Completion tracking: Require passing grade
    q.sumgrades,                    # Quiz points total
	q.grade,                        # Quiz grade

	-- Grade to pass
    (SELECT gi.gradepass FROM [prefix]grade_items AS gi
		WHERE gi.iteminstance = q.id AND gi.itemmodule = 'quiz') AS 'gradetopass',

  -- Quiz created/modified
	FROM_UNIXTIME(q.timecreated) AS 'quiztimecreated',
	FROM_UNIXTIME(q.timemodified) AS 'quiztimemodified'

FROM [prefix]quiz AS q
JOIN [prefix]course_modules AS cm
  ON q.course = cm.course AND q.id = cm.instance

WHERE cm.id IN ([module.id]);
