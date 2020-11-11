
SELECT na.userID, 
		 if(na.text IS NOT NULL,1,0) AS aim_exist,
		 case 
			when afc.afn=1 then 0.1 
			when afc.afn IN (2,5) then 0.2
			when afc.afn>5 then 0.3
			ELSE 0 
		 END AS aim_feedback, 
		 case 
		 	when length(na.text) IN (10,150) then 0.1
		 	when length(na.text) IN (150,350) then 0.2
		 	when length(na.text)>350 then 0.3
			ELSE 0 	
		 END AS aim_length,
		 if(user_bet_feedback.ubf_count IS NOT NULL,user_bet_feedback.ubf_count/10,0) AS feedback_bet
FROM now.aim AS na
	LEFT JOIN 
		(SELECT AF.aimID, COUNT(*) AS afn
		FROM now.aim_feedback AS AF 
		GROUP BY AF.aimID) AS afc
	ON afc.aimID=na.id
	LEFT JOIN 
		(
		SELECT COUNT(DISTINCT(ua.eventID)) AS ubf_count, ua.userID 	
		FROM  labs.user_auction AS ua, labs.user_feedback_answer AS ufa
		WHERE ua.bet IS NOT NULL AND ua.bet>0 and
			  ufa.userID=ua.userID AND ufa.eventID=ua.eventID
		GROUP BY ua.userID) AS user_bet_feedback 
	ON user_bet_feedback.userID=na.userID
WHERE na.createDT>=STR_TO_DATE("08 07 2019","%e %m %Y") AND
		na.createDT<=STR_TO_DATE("22 07 2019","%e %m %Y")
GROUP by na.userID, na.text;
