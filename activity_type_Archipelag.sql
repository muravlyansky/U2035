SELECT ty.title, ty.id AS type_id, COUNT(a.title) AS count_activity
FROM labs.activity AS a
	LEFT JOIN labs.activity_type at ON a.id = at.activityID
	LEFT JOIN labs.type ty ON at.typeID = ty.id
	LEFT JOIN labs.context_activity AS ca ON ca.activityID=a.id
WHERE ca.contextID=355
GROUP BY ty.id; 
