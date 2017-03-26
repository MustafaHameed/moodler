SELECT

  -- Quiz related
  q.course AS 'course.id',
  cm.id AS 'quiz.id',
  
  -- Question related  
  CASE que.qtype WHEN 'multichoice'
    THEN concat (
      que.qtype, '_', (
        SELECT CASE qmu.single WHEN 0 THEN 'multiple' ELSE 'one' END
        FROM [prefix]qtype_multichoice_options AS qmu
        WHERE qmu.questionid = que.id)
      )
     ELSE que.qtype
  END AS 'question.type',
  quea.questionid AS 'question.id',
  COUNT(quea.questionid) AS 'question.attempts',   # toto k něčemu potřebujeme?
  que.name AS 'question.name',
  que.questiontext AS 'question.text',
  qs.maxmark AS 'question.maxpoints',
  quea.minfraction AS 'question.mingrade'

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

WHERE cm.id IN ([module.id])

GROUP BY q.id, quea.questionid

ORDER BY q.id, quea.questionid;
