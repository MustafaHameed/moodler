SELECT

  -- Quiz/User/Attempt
  q.course AS 'course.id',
  cm.id AS 'quiz.id',
  #quiza.userid AS 'user.id',
  quiza.id AS 'attempt.id',

  -- Question related
  que.qtype AS 'question.type',
  que.id AS 'question.id',
  quea.maxmark AS 'question.maxpoints.past',
# (SELECT saq.usecase FROM [prefix]qtype_shortanswer_options AS saq
# WHERE saq.questionid = que.id) AS 'case.sensitivity',            # 0 = No, 1 = Yes

  -- Answer related
  queasd.name AS 'answer.data',
  queasd.VALUE AS 'answer.text',
  queas.fraction AS 'answer.percent',
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
LEFT JOIN [prefix]question_attempt_step_data AS queasd
  ON queasd.attemptstepid = queas.id

WHERE quiza.preview = 0 AND
      queasd.name IN ('answer','-finish') AND
      que.qtype = 'shortanswer' AND
      quiza.id IN ([attempt.id])

ORDER BY quiza.quiz, quiza.userid, quiza.id, quea.questionid;
