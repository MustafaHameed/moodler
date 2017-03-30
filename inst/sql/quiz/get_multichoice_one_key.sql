SELECT

  -- Question related
  que.id AS 'question.id',
  'multichoice_one' AS 'question.type',  
  que.name AS 'question.name',
  que.questiontext AS 'question.text',

  -- Answer related
  qans.id AS 'answer.id',
  qans.answer AS 'answer.text',
  qans.fraction AS 'answer.percent'

FROM [prefix]question AS que
JOIN [prefix]question_answers AS qans
  ON que.id = qans.question
JOIN [prefix]qtype_multichoice_options AS qmu
  ON que.id = qmu.questionid

WHERE que.qtype = 'multichoice' AND qmu.single = 1 AND # 1 = multichoice_one
      que.id IN ([question.id])

ORDER BY que.id, qans.id;
