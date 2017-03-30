SELECT

  -- Question related
  que.id AS 'question.id',
  que.qtype AS 'question.type',  
  que.name AS 'question.name',
  que.questiontext AS 'question.text',

  -- Subquestions related
  quemulti.sequence AS 'subquestions.ids'

FROM [prefix]question AS que
JOIN [prefix]question_multianswer AS quemulti
  ON quemulti.question = que.id 

WHERE que.qtype = 'multianswer' AND
      que.id IN ([question.id])

ORDER BY que.id, qans.id;