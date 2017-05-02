SELECT

  -- Attempt related
  quiza.id AS 'attempt.id',

  -- Question related
  que.id AS 'question.id',
  quea.maxmark AS 'question.maxpoints',
  quea.minfraction AS 'question.mingrade',

  -- Answer related
  queasd.name AS 'answer.data',
  queasd.VALUE AS 'answer.id',
  queas.fraction AS 'answer.percent',  
  FROM_UNIXTIME(queas.timecreated) AS 'answer.time'

FROM [prefix]quiz_attempts AS quiza
JOIN [prefix]question_attempts AS quea
  ON quea.questionusageid = quiza.uniqueid
JOIN [prefix]question AS que
  ON quea.questionid = que.id
JOIN [prefix]qtype_multichoice_options AS qmu
  ON que.id = qmu.questionid
JOIN [prefix]question_attempt_steps AS queas
  ON queas.questionattemptid = quea.id
JOIN [prefix]question_attempt_step_data AS queasd
  ON queasd.attemptstepid = queas.id

WHERE quiza.preview = 0 AND
      (queasd.name IN ('_order','-comment') OR queasd.name LIKE 'choice%') AND
      que.qtype = 'multichoice' AND qmu.single = 0 AND # 0 = multichoice_multiple
      quiza.id IN ([attempt.id])

ORDER BY quiza.quiz, quiza.userid, quiza.id, quea.questionid, queas.timecreated;
