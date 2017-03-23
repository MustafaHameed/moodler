SELECT

  -- id/name
  q.id AS 'quiz.id',
  cm.id AS 'quiz.cmid',
  q.name AS 'quiz.name',

  -- Attempt count
    (SELECT COUNT(qa.id) FROM mdl_quiz_attempts AS qa
		WHERE q.id = qa.quiz GROUP BY qa.quiz) AS 'attemptscount',

  -- Sections
    (SELECT COUNT(qsec.id) FROM mdl_quiz_sections AS qsec
		WHERE q.id = qsec.quizid) AS 'sectionscount',

	-- Paging
    (SELECT COUNT(DISTINCT qslot.page) FROM mdl_quiz_slots AS qslot
		WHERE q.id = qslot.quizid) AS 'pagecount',

  -- Item count (incl. descr.)
    (SELECT COUNT(qslot.id) FROM mdl_quiz_slots AS qslot
		WHERE q.id = qslot.quizid) AS 'allquestioncount',

	-- How many different types of items are there
    (SELECT COUNT(DISTINCT que.qtype) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid) AS 'difqtypecount',

  -- Item count by type
    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'ddimageortext') AS 'ddimageortextquestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'ddmarker') AS 'ddmarkerquestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'ddwtos') AS 'ddwtosquestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'description') AS 'descriptionquestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'essay') AS 'essayquestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'gapselect') AS 'gapselectquestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'match') AS 'matchquestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'multichoice') AS 'multichoicequestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'numerical') AS 'numericalquestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'order') AS 'orderquestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'random') AS 'randomquestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'randomsamatch') AS 'randomsamatchquestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'shortanswer') AS 'shortanswerquestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'truefalse') AS 'truefalsequestioncount',

    (SELECT COUNT(que.id) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'multianswer') AS 'multianswerquestioncount',

	-- How many sub-items within multianswer items
    (SELECT SUM((SELECT COUNT(queque.id) FROM mdl_question AS queque
        WHERE queque.parent = que.id)) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'multianswer'
        GROUP BY q.id) AS 'masubquestioncount',

  -- Item counts by type within multianswer items
    (SELECT SUM((SELECT COUNT(queque.id) FROM mdl_question AS queque
        WHERE queque.parent = que.id AND queque.qtype = 'shortanswer')) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'multianswer'
        GROUP BY q.id) AS 'mashortanswercount',

    (SELECT SUM((SELECT COUNT(queque.id) FROM mdl_question AS queque
        WHERE queque.parent = que.id AND queque.qtype = 'multichoice')) FROM mdl_quiz_slots AS qslot
		JOIN mdl_question AS que ON qslot.questionid = que.id
		WHERE q.id = qslot.quizid AND que.qtype = 'multianswer'
        GROUP BY q.id) AS 'mamultichoicecount',

  -- Random question order?
    (SELECT SUM(qsec.shufflequestions) FROM mdl_quiz_sections AS qsec
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
    (SELECT gi.gradepass FROM mdl_grade_items AS gi
		WHERE gi.iteminstance = q.id AND gi.itemmodule = 'quiz') AS 'gradetopass',

	-- Nastavení zpětné vazby (bit field). re: na toto bych se možná vykašlal...
    q.reviewattempt,
	  q.reviewcorrectness,
	  q.reviewmarks,
	  q.reviewspecificfeedback,
	  q.reviewgeneralfeedback,
	  q.reviewrightanswer,
	  q.reviewoverallfeedback,

  -- Quiz created/modified
	  FROM_UNIXTIME(q.timecreated) AS 'quiztimecreated',
	  FROM_UNIXTIME(q.timemodified) AS 'quiztimemodified'

FROM mdl_quiz AS q
JOIN mdl_course_modules AS cm
  ON q.course = cm.course AND q.id = cm.instance

WHERE q.course = [course.id] AND cm.id = [module.id];
