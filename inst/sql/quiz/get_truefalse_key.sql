SELECT

  q.course AS 'course.id',
  cm.id AS 'quiz.id',
  que.qtype AS 'question.type',
  quea.questionid AS 'question.id',
  COUNT(quea.questionid) AS 'question.attempts',   # toto k něčemu potřebujeme?
  qans.id AS 'response.id',   
  qans.answer AS 'response.text',
  qans.fraction AS 'response.percent'

FROM mdl_quiz AS q
JOIN mdl_course_modules AS cm
    ON q.course = cm.course AND q.id = cm.instance
JOIN mdl_quiz_attempts AS qa
    ON q.id = qa.quiz
JOIN mdl_question_attempts AS quea
    ON qa.uniqueid = quea.questionusageid
JOIN mdl_question AS que
  ON quea.questionid = que.id
LEFT JOIN mdl_question_answers AS qans
    ON quea.questionid = qans.question

WHERE que.qtype = 'truefalse' AND 
      cm.id IN ([module.id])

GROUP BY q.id, quea.questionid, qans.id

ORDER BY q.id, quea.questionid;