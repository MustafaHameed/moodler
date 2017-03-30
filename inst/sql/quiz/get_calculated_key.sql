SELECT

  -- Question related
  que.id AS 'question.id',
  que.qtype AS 'question.type',  
  que.name AS 'question.name',
  que.questiontext AS 'question.text',

  -- Answer related
  qans.id AS 'answer.id',
  qans.answer AS 'answer.text',                                   # = answer formula
  quecalc.tolerance AS 'answer.tolerance',
  quecalc.tolerancetype AS 'answer.tolerancetype',                # 1 = relative, 2 = nominal, 3 = geometric
  quecalc.correctanswerlength AS 'answer.correctanswerlength',
  quecalc.correctanswerformat AS 'answer.correctanswerformat',    # 1 = decimals, 2 = significant figures
  qans.fraction AS 'answer.percent'
  

FROM [prefix]question AS que
JOIN [prefix]question_answers AS qans
  ON que.id = qans.question
JOIN [prefix]question_calculated AS quecalc
  ON que.id = quecalc.question AND qans.id = quecalc.answer

WHERE que.qtype = 'calculated' AND
      que.id IN ([question.id])

ORDER BY que.id, qans.id;