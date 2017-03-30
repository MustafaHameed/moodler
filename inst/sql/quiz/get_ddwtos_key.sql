SELECT

  -- Question related
  que.id AS 'question.id',
  que.qtype AS 'question.type',  
  que.name AS 'question.name',
  que.questiontext AS 'question.text',
  
  -- Answer related   
  qans.id AS 'answer.id',   
  qans.answer AS 'answer.text',
  SUBSTRING(qans.feedback, 40, 1) AS 'answer.group',    # Spoléhá na jednočíslený počet skupin (výchozí = max 8)
  SUBSTRING(qans.feedback, 60, 1) AS 'answer.unlimited' # 0 = No; 1 = Yes

FROM [prefix]question AS que
JOIN [prefix]question_answers AS qans
  ON que.id = qans.question

WHERE que.qtype = 'ddwtos' AND 
      que.id IN ([question.id])

ORDER BY que.id, qans.id;