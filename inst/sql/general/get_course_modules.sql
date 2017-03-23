SELECT

  cm.course AS 'course.id',
  s.section AS 'module.section',
  s.name AS 'section.name',
  m.name AS 'module.type',
  cm.id AS 'module.id',              # cmid is useful to query individual modules, visible in browser
  cm.instance AS 'module.instance',  # id is useful to obtain module names
  m.visible AS 'module.visibility'

FROM [prefix]course_modules AS cm
JOIN [prefix]modules AS m ON cm.module = m.id
JOIN [prefix]course_sections AS s ON s.id = cm.section

WHERE cm.course IN ([course.id])

ORDER BY cm.course, cm.section;

