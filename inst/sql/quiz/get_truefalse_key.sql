SELECT

  -- Question related
  que.id AS 'question.id',
  que.qtype AS 'question.type',  
  que.name AS 'question.name',
  que.questiontext AS 'question.text',
  
  -- Answer related
  qans.id AS 'answer.id',   
  qans.answer AS 'answer.text',
  qans.fraction AS 'answer.percent'

FROM [prefix]question AS que
JOIN [prefix]question_answers AS qans
  ON que.id = qans.question

WHERE que.qtype = 'truefalse' AND 
      que.id IN ([question.id])

ORDER BY que.id, qans.id;
