SELECT

  -- Quiz/User/Attempt
  q.course AS 'course.id',
  cm.id AS 'quiz.id',
  quiza.userid AS 'user.id',
  quiza.id AS 'attempt.id',
  
  -- Question related  
  que.qtype AS 'question.type',  
  que.id AS 'question.id',
  que.name AS 'question.name',                # Je i v get_questions, ale možná se hodí i sem?
  que.questiontext AS 'question.text',
  qs.maxmark AS 'question.maxpoints',         # Počet bodů jak je aktuálně nastaven na stránce "Upravit test" 
  quea.maxmark AS 'question.maxpoints.past',  # Je to třeba?
  quea.minfraction AS 'question.mingrade',    # Toto jsme tam měly kůli možným záporným bodům
  
  -- Answer related  
  CASE queasd.VALUE WHEN 0 THEN 'False' ELSE 'True' END AS 'users.answer', # Tj. co uživatel zvybral jako odpověď.
  FROM_UNIXTIME(queas.timecreated) AS 'answer.time' # V některých případech/režimech tesů může mít jedna otázka více 
													# řádků, řádek s nejpozdějším časem by měla být finální odpověď.

FROM mdl_quiz AS q
JOIN mdl_course_modules AS cm
  ON q.course = cm.course AND q.id = cm.instance
JOIN mdl_quiz_attempts AS quiza
  ON q.id = quiza.quiz
JOIN mdl_question_attempts AS quea
  ON quea.questionusageid = quiza.uniqueid
JOIN mdl_question AS que
  ON quea.questionid = que.id
JOIN mdl_quiz_slots AS qs
  ON q.id = qs.quizid AND que.id = qs.questionid
JOIN mdl_question_attempt_steps AS queas
  ON queas.questionattemptid = quea.id
LEFT JOIN mdl_question_attempt_step_data AS queasd
  ON queasd.attemptstepid = queas.id

WHERE quiza.preview = 0 AND
      queasd.name = 'answer' AND
      que.qtype = 'truefalse' AND
      quiza.id IN ([attempt.id])

ORDER BY quiza.quiz, quiza.userid, quiza.id, quea.questionid;