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
  
  -- Answer related   
  qans.id AS 'response.id',   
  qans.answer AS 'response.text',
  qans.fraction AS 'response.percent'

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

WHERE que.qtype = 'truefalse' AND 
      cm.id IN ([module.id])

GROUP BY q.id, quea.questionid, qans.id

ORDER BY q.id, quea.questionid;