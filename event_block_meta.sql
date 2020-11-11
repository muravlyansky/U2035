
SELECT  a.title AS activity_title,
		  e.title AS event_title,
		  b.title AS block_title,
 		  br.title AS block_result,
 		  br.meta
FROM labs.block_result AS br
LEFT JOIN labs.block AS b ON b.id=br.blockID
LEFT JOIN labs.event AS e ON b.eventID=e.id
LEFT JOIN labs.run r on r.id = e.runID 
LEFT JOIN labs.activity a on a.id=r.activityID
LEFT JOIN labs.context_activity ca on ca.activityID = a.id and ca.contextID=252
WHERE  br.meta IS NOT NULL AND br.meta<>'' AND a.id IS NOT NULL AND ca.contextID IS NOT NULL;
