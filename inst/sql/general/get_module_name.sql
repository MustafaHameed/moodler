SELECT

  module.id AS 'module.id',
  module.name AS 'module.name',
  module.course AS 'course.id'

FROM [prefix][module.type] AS module #replace in R with required module type (such as "quiz")

WHERE module.course IN ([course.id]);
