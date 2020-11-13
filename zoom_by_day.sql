-- Собираем имена Zoom участников и e-mail + количество сессий  в день
WITH const AS 
	  (SELECT   1 AS day_id, STR_TO_DATE("07 11 2020","%d %m %Y") AS day_n 	   UNION
		SELECT   2 AS day_id, STR_TO_DATE("08 11 2020","%d %m %Y") AS day_n	   UNION
		SELECT   3 AS day_id, STR_TO_DATE("09 11 2020","%d %m %Y") AS day_n	   UNION
		SELECT   4 AS day_id, STR_TO_DATE("10 11 2020","%d %m %Y") AS day_n	   UNION
		SELECT   5 AS day_id, STR_TO_DATE("11 11 2020","%d %m %Y") AS day_n	   UNION
		SELECT   6 AS day_id, STR_TO_DATE("12 11 2020","%d %m %Y") AS day_n		UNION
		SELECT   7 AS day_id, STR_TO_DATE("13 11 2020","%d %m %Y") AS day_n			
	  )
SELECT user_name, email, const.day_n AS 'День' , zoom_count
FROM  const
LEFT JOIN (
				SELECT lmp.user_name, lmp.email, const.day_n , COUNT(lmp.meeting_id) AS zoom_count
				FROM  prd_analytics.list_meetings_participants AS lmp  
				JOIN const
				WHERE lmp.join_time>=const.day_n AND lmp.join_time<const.day_n+1  AND
						lmp.user_name NOT LIKE '___zal@a5000.ru%' AND lmp.email NOT LIKE '___zal@a5000.ru%'
				GROUP BY lmp.user_name, const.day_n
				HAVING COUNT(DISTINCT lmp.email)<=1
			 ) AS zoom
		ON zoom.day_n=const.day_n	;
