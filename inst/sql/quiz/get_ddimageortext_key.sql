SELECT

  -- Question related
  que.id AS 'question.id',
  que.qtype AS 'question.type',  
  que.name AS 'question.name',
  que.questiontext AS 'question.text',
  
  -- Answer related   
  ddidrags.no AS 'answer.id',   
  ddidrags.draggroup AS 'answer.group',
  ddidrags.infinite AS 'answer.unlimited',      # 1 = True, 0 = False
  ddidrags.label AS 'answer.label',             # optional
  
  -- Dropzone related
  ddidrops.no AS 'correct.dropzone',
  ddidrops.label AS 'dropzone.label'            # optional

FROM [prefix]question AS que
JOIN [prefix]qtype_ddimageortext_drags AS ddidrags
  ON ddidrags.questionid = que.id
LEFT JOIN [prefix]qtype_ddimageortext_drops AS ddidrops
  ON ddidrops.questionid = que.id AND ddidrags.no = ddidrops.choice   

WHERE que.qtype = 'ddimageortext' AND 
      que.id IN ([question.id])

ORDER BY que.id, ddidrags.no;
