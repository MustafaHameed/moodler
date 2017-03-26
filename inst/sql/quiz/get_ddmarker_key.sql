SELECT

  -- Quiz related
  q.course AS 'course.id',
  cm.id AS 'quiz.id',
  
  -- Question related  
  que.qtype AS 'question.type',
  quea.questionid AS 'question.id',
  COUNT(quea.questionid) AS 'question.attempts',  # Toto k něčemu potřebujeme?
  que.name AS 'question.name',
  que.questiontext AS 'question.text',
  qs.maxmark AS 'question.maxpoints',
  quea.minfraction AS 'question.mingrade',
  quea.rightanswer AS 'right.answers',            # Zatím nechávám, zřejmě není třeba.
  
  -- Answer related   
  ddmdrags.no AS 'answer.id',   
  ddmdrags.infinite AS 'answer.unlimited',
  ddmdrags.noofdrags AS 'answer.noofdrags',
  ddmdrags.label AS 'answer.label',
  
  -- Dropzone related
  ddmdrops.no AS 'correct.dropzone',
  ddmdrops.shape AS 'dropzone.shape',
  ddmdrops.coords AS 'dropzone.coords' 

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
JOIN [prefix]qtype_ddmarker_drags AS ddmdrags
  ON ddmdrags.questionid = que.id
LEFT JOIN [prefix]qtype_ddmarker_drops AS ddmdrops
  ON ddmdrops.questionid = que.id AND ddmdrags.no = ddmdrops.choice   

WHERE que.qtype = 'ddmarker' AND 
      cm.id IN ([module.id])

GROUP BY q.id, quea.questionid, ddmdrags.id, ddmdrops.id

ORDER BY q.id, quea.questionid;