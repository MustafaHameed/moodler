SELECT

  -- Quiz-related
  cm.id AS 'quiz.cmid',
  q.name AS 'quiz.name',

  -- Question layout
  qs.slot AS 'slot.number',
  qs.page AS 'page.number',

  -- Question-related
  que.id AS 'question.id',
  CASE que.qtype WHEN 'multichoice'
    THEN concat (
      que.qtype, '_', (
        SELECT CASE qmu.single WHEN 0 THEN 'multiple' ELSE 'one' END
        FROM [prefix]qtype_multichoice_options AS qmu
        WHERE qmu.questionid = que.id)
      )
     ELSE que.qtype
  END AS 'question.type',
  que.name AS 'question.name'

FROM [prefix]quiz AS q
JOIN [prefix]course_modules AS cm
  ON q.course = cm.course AND q.id = cm.instance
JOIN [prefix]quiz_slots AS qs
  ON q.id = qs.quizid
JOIN [prefix]question AS que
  ON que.id = qs.questionid

WHERE cm.id IN ([module.id]);
