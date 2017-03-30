SELECT

  -- Question related
  que.id AS 'question.id',
  que.qtype AS 'question.type',  
  que.name AS 'question.name',
  que.questiontext AS 'question.text',
  
  -- Answer related   
  ddmdrags.no AS 'answer.id',   
  ddmdrags.infinite AS 'answer.unlimited',
  ddmdrags.noofdrags AS 'answer.noofdrags',
  ddmdrags.label AS 'answer.label',
  
  -- Dropzone related
  ddmdrops.no AS 'correct.dropzone',
  ddmdrops.shape AS 'dropzone.shape',
  ddmdrops.coords AS 'dropzone.coords' 

FROM [prefix]question AS que
JOIN [prefix]qtype_ddmarker_drags AS ddmdrags
  ON que.id = ddmdrags.questionid
LEFT JOIN [prefix]qtype_ddmarker_drops AS ddmdrops
  ON que.id = ddmdrops.questionid AND ddmdrags.no = ddmdrops.choice   

WHERE que.qtype = 'ddmarker' AND 
      que.id IN ([question.id])

ORDER BY que.id, ddmdrags.no;