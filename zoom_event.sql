SELECT SUBSTR(e.meeting_link,LENGTH('https://zoom.us/j/')+1) AS meeting_id,
										t.title AS event_type
								FROM labs.event AS e 
								LEFT JOIN labs.run AS r ON e.runID=r.id
								LEFT JOIN labs.activity AS a ON r.activityID = a.id
								LEFT JOIN labs.activity_type lat ON a.id = lat.activityID  
								LEFT JOIN labs.`type` as t ON  lat.typeID=t.id
								WHERE e.meeting_link LIKE 'https://zoom.us/j/%';
