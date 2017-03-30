SELECT

  -- Quiz/User/Attempt
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
  quea.maxmark AS 'question.maxpoints',
  quea.minfraction AS 'question.mingrade',
  
  -- Answer related
  queas.fraction AS 'answer.percent',                 # Procento získaných bodů za úlohu
  FROM_UNIXTIME(queas.timecreated) AS 'answer.time'

FROM [prefix]quiz_attempts AS quiza
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
