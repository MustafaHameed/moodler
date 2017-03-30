SELECT

  -- Question related
  que.id AS 'question.id',
  que.qtype AS 'question.type',  
  que.name AS 'question.name',
  que.questiontext AS 'question.text',

  -- Subquestion and answer related
  quematch.id AS 'answer.id',
  quematch.questiontext AS 'subquestion.text',
  quematch.answertext AS 'answer.text'


FROM [prefix]question AS que
JOIN [prefix]qtype_match_subquestions AS quematch
  ON que.id = quematch.questionid

WHERE que.qtype = 'match' AND
      que.id IN ([question.id])

ORDER BY que.id, quematch.id;