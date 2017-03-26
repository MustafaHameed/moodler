SELECT

  -- Quiz/User/Attempt
  q.course AS 'course.id',
  cm.id AS 'quiz.id',
  quiza.userid AS 'user.id',
  quiza.id AS 'attempt.id',
  
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
  que.id AS 'question.id',
  quea.maxmark AS 'question.maxpoints.past',
  
  -- Answer related
  queas.fraction AS 'answer.percent',                 # Procento získaných bodů za úlohu
  FROM_UNIXTIME(queas.timecreated) AS 'answer.time'

FROM [prefix]quiz AS q
JOIN [prefix]course_modules AS cm
  ON q.course = cm.course AND q.id = cm.instance
JOIN [prefix]quiz_attempts AS quiza
  ON q.id = quiza.quiz
JOIN [prefix]question_attempts AS quea
  ON quea.questionusageid = quiza.uniqueid
JOIN [prefix]question AS que
  ON quea.questionid = que.id
JOIN [prefix]question_attempt_steps AS queas
  ON queas.questionattemptid = quea.id

WHERE quiza.preview = 0 AND
      queas.state IN ('gradedright', 'gradedwrong', 'gradedpartial') AND
      quiza.id IN ([attempt.id])

ORDER BY quiza.quiz, quiza.userid, quiza.id, quea.questionid, queas.timecreated;
