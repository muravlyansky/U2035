SELECT lmp.user_name, lmp.meeting_id, lmp.email, SUM(lmp.leave_time - lmp.join_time) AS time_on, DATE_FORMAT(MIN(lmp.join_time),"%d.%m.%Y") AS 'День'
	FROM  prd_analytics.list_meetings_participants AS lmp 
	WHERE lmp.user_name NOT LIKE '___zal@a5000.ru%' AND lmp.email NOT LIKE '___zal@a5000.ru%'
	GROUP BY lmp.user_name, lmp.meeting_id, lmp.email;	
