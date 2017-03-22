SELECT

  -- Quiz-related
  q.id AS 'quiz.id',
  cm.id AS 'quiz.cmid',
  q.name AS 'quiz.name',

  -- Question layout
  qs.slot AS 'slot.number',
  qs.page AS 'page.number',

  -- Question-related
  que.id AS 'question.id',
  que.qtype AS 'question.type',
  que.name AS 'question.name'

FROM mdl_quiz AS q
JOIN mdl_course_modules AS cm
  ON q.course = cm.course AND q.id = cm.instance
JOIN mdl_quiz_slots AS qs
  ON q.id = qs.quizid
JOIN mdl_question AS que
  ON que.id = qs.questionid

WHERE q.course = [course.id] AND cm.id = [module.id];

-- WHERE q.course = 4094 AND cm.id = 281948; -- Test s náhodnými úlohami
