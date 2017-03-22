SELECT 
  
  module.id AS 'module.id',
  module.name AS 'module.name'
  
FROM mdl_quiz AS module  # "mdl_quiz" se nahrazuje daným typem, tj. "mdl_{type}"


WHERE module.course IN (4124) AND  # při volání z více kurzů lze stejný typ tahat jedním dotazem ze všech kurzů
      module.id IN (40586,40585,40584,40583,40582,44298) # IDs pro daný typ (získaný přes get_course_modules)
;

