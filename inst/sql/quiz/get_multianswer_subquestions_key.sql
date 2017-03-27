SELECT

  -- Parent question related
  que.parent AS 'question.id',

  -- Subquestion related
  CASE que.qtype WHEN 'multichoice'
    THEN 'multichoice_one'
	ELSE que.qtype
  END AS 'subquestion.type',
  que.id AS 'subquestion.id',
  que.name AS 'subquestion.name',
  que.questiontext AS 'subquestion.text',

  -- Subquestions answers related
  qans.id AS 'answer.id',
  qans.answer AS 'answer.text',
  quenum.tolerance AS 'answer.tolerance',  # Pro případ numerických podotázek.
  qans.fraction AS 'answer.percent'  

FROM [prefix]question AS que
JOIN [prefix]question_answers AS qans
  ON que.id = qans.question
LEFT JOIN [prefix]question_numerical AS quenum
  ON quenum.question = que.id AND quenum.answer = qans.id    

WHERE que.id  IN ([subquestion.id]) OR      # Buď lze tahat přes id podotázek (vytáhne get_multianswer_key)...
      que.parent IN ([question.id])         # ... nebo přes id celých CLOZE otázek.

ORDER BY que.id, qans.id;