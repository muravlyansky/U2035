			SELECT 	ua.userID,
						IF (ua.bet IS NOT NULL, 0.1, 0) AS bet_factor, 
						date_format(ua.createDT, "%Y-%m-%e") AS DATE,
						ua.bet, ua.eventID, ua.createDT, ufa.eventID, ufa.value, ufa.`data`, ufa.createDT
			FROM  labs.user_auction AS ua, labs.user_feedback_answer AS ufa
			WHERE ua.bet IS NOT NULL AND 
					ua.bet>0 AND
				  	ufa.userID=ua.userID AND 
					ufa.eventID=ua.eventID AND
					ua.createDT>=STR_TO_DATE("08 07 2019","%e %m %Y") AND
					ua.createDT<=STR_TO_DATE("22 07 2019","%e %m %Y");
