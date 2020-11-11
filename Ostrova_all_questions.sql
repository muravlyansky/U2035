
SELECT fq.title, fq.id

FROM (		
	SELECT c.title AS Контекст,  a.title AS activity_title,
			 GROUP_CONCAT(distinct author.title) AS aa, a.id
	FROM 
	labs.context AS c 
	LEFT JOIN labs.context_activity AS ca ON c.id=ca.contextID
	LEFT JOIN labs.activity AS a ON ca.activityID=a.id
	LEFT JOIN labs.activity_author AS aa ON aa.activityID =a.id
	LEFT JOIN labs.author ON author.id=aa.authorID
	WHERE c.title IN ('Остров 10-21','Остров 10-22','Зимний остров')
	GROUP BY c.id,  a.title ) AS a_t
LEFT JOIN labs.run r on a_t.id=r.activityID
LEFT JOIN labs.event AS e ON e.runID=r.id
LEFT JOIN labs.event_author AS ae ON ae.eventID=e.id
LEFT JOIN labs.author ON author.id=ae.authorID
LEFT JOIN labs.user_feedback_answer AS ufa ON e.id=ufa.eventID
LEFT JOIN labs.feedback_question AS fq ON ufa.feedbackQuestionID=fq.id	
GROUP BY fq.id
