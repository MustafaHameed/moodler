SELECT

  -- Question related
  que.id AS 'question.id',
  que.qtype AS 'question.type',  
  que.name AS 'question.name',
  que.questiontext AS 'question.text',

  -- Answer related
  qans.id AS 'answer.id',
  qans.answer AS 'answer.text',
  quenum.tolerance AS 'answer.tolerance',
  qans.fraction AS 'answer.percent'

FROM [prefix]question AS que
JOIN [prefix]question_answers AS qans
  ON que.id = qans.question
JOIN [prefix]question_numerical AS quenum
  ON que.id = quenum.question AND qans.id = quenum.answer

WHERE que.qtype = 'numerical' AND
      que.id IN ([question.id])

ORDER BY que.id, qans.id;
