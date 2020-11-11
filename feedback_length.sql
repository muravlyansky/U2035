SELECT aimID,  SUM(feedback_length) AS length_factor, GROUP_CONCAT(rating) AS R_chain,
		 case 
			when COUNT(*)=1 then 0.1 
			when COUNT(*) IN (2,5) then 0.2
			when COUNT(*)>5 then 0.3
			ELSE 0 
		 END AS feedback_factor
FROM
(SELECT 	case 
		 		when length(naf.text) IN (10,60) then 0.1
		 		when length(naf.text) IN (61,200) then 0.2
		 		when length(naf.text)>201 then 0.3
			ELSE 0 	
		 END AS feedback_length,
		 naf.rating , 
		 naf.aimID 
 FROM now.aim_feedback  AS naf
 ORDER BY naf.aimID, naf.createDT ASC) AS naf_length
GROUP BY naf_length.aimID
