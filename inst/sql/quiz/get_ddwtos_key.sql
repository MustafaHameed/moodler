SELECT

  -- Quiz related
  q.course AS 'course.id',
  cm.id AS 'quiz.id',
  
  -- Question related  
  que.qtype AS 'question.type',
  quea.questionid AS 'question.id',
  COUNT(quea.questionid) AS 'question.attempts',   # toto k něčemu potřebujeme?
  que.name AS 'question.name',
  que.questiontext AS 'question.text',
  qs.maxmark AS 'question.maxpoints',
  quea.minfraction AS 'question.mingrade',
  quea.rightanswer AS 'right.answers',             # Zatím nechávám, zřejmě není třeba.
  
  -- Answer related   
  qans.id AS 'response.id',   
  qans.answer AS 'response.text',
  SUBSTRING(qans.feedback, 40, 1) AS 'response.group',    # Spoléhá na jednočíslený počet skupin (výchozí = max 8)
  SUBSTRING(qans.feedback, 60, 1) AS 'response.unlimited' # 0 = No; 1 = Yes

FROM [prefix]quiz AS q
JOIN [prefix]course_modules AS cm
  ON q.course = cm.course AND q.id = cm.instance
JOIN [prefix]quiz_attempts AS qa
  ON q.id = qa.quiz
JOIN [prefix]question_attempts AS quea
  ON qa.uniqueid = quea.questionusageid
JOIN [prefix]question AS que
  ON quea.questionid = que.id
JOIN [prefix]quiz_slots AS qs
  ON q.id = qs.quizid AND que.id = qs.questionid  
LEFT JOIN [prefix]question_answers AS qans
  ON quea.questionid = qans.question

WHERE que.qtype = 'ddwtos' AND 
      cm.id IN ([module.id])

GROUP BY q.id, quea.questionid, qans.id

ORDER BY q.id, quea.questionid;