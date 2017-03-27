SELECT

  -- Quiz/User/Attempt
  q.course AS 'course.id',
  cm.id AS 'quiz.id',
  # quiza.userid AS 'user.id',
  quiza.id AS 'attempt.id',

  -- Question related
  'multichoice_multiple' AS 'question.type',       # Zbytečné? Příp. rychlejší přes R?
  que.id AS 'question.id',
  quea.maxmark AS 'question.maxpoints.past',

  -- Answer related
  queasd.name AS 'answer.data',
  queasd.VALUE AS 'answer.id',
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
JOIN [prefix]qtype_multichoice_options AS qmu
  ON qmu.questionid = que.id
JOIN [prefix]question_attempt_steps AS queas
  ON queas.questionattemptid = quea.id
LEFT JOIN [prefix]question_attempt_step_data AS queasd
  ON queasd.attemptstepid = queas.id

WHERE quiza.preview = 0 AND
      (queasd.name = '_order' OR queasd.name LIKE 'choice%') AND
      que.qtype = 'multichoice' AND qmu.single = 0 AND # 0 = multichoice_multiple
      quiza.id IN ([attempt.id])

ORDER BY quiza.quiz, quiza.userid, quiza.id, quea.questionid;
