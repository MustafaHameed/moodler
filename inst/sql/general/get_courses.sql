SELECT

  c.id AS 'course.id',
  c.shortname AS 'course.shortname',
  c.fullname AS 'course.fullname',
  c.visible AS 'course.visible',
  FROM_UNIXTIME(c.timecreated) AS 'course.timecreated',
  FROM_UNIXTIME(c.timemodified) AS 'course.timemodified',
  (SELECT cc.id FROM [prefix]course_categories AS cc
		WHERE cc.id = c.category) AS 'course.categoryid',
  (SELECT cc.name FROM [prefix]course_categories AS cc
		WHERE cc.id = c.category) AS 'course.categoryname'

FROM [prefix]course AS c;

