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
  ddidrags.no AS 'response.id',   
  ddidrags.draggroup AS 'response.group',
  ddidrags.infinite AS 'response.unlimited',
  ddidrags.label AS 'response.label',             # Reálně je nepovinné (lze použít jen img), chceme nechat?
  
  -- Dropzone related
  ddidrops.no AS 'correct.dropzone',
  ddidrops.label AS 'dropzone.label'              # Rovněž nepovinné (a asi ani často využívané)...

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
JOIN [prefix]qtype_ddimageortext_drags AS ddidrags
  ON ddidrags.questionid = que.id
LEFT JOIN [prefix]qtype_ddimageortext_drops AS ddidrops
  ON ddidrops.questionid = que.id AND ddidrags.no = ddidrops.choice   

WHERE que.qtype = 'ddimageortext' AND 
      cm.id IN ([module.id])

GROUP BY q.id, quea.questionid, ddidrags.id, ddidrops.id

ORDER BY q.id, quea.questionid;
