WITH const AS 
	  (SELECT   STR_TO_DATE("30 03 2020","%d %m %Y") AS begin_date,
		 			STR_TO_DATE("06 05 2020","%d %m %Y") AS end_date,
		 			STR_TO_DATE("30 03 2020","%d %m %Y") AS intens_start_date
	  ),	
	uid AS 
	(SELECT distinct untiID, leaderID, userID  AS ple_userID FROM ple.user_info  as ui 
	 WHERE ui.untiID IS NOT NULL AND 
	        ui.userID IN (SELECT userID 
						  FROM ple.user_tag WHERE tagID IN 
									(SELECT id FROM ple.tag WHERE title in 
										('p1_ncfu_student_ss20', 'p1_sevsu_student_ss20', 'p1_vyatsu_student_ss20',
										'p1_rsue_student_ss20', 'p1_chuvsu_student_ss20', 'p1_sfu_student_ss20',
										'p1_vstu_student_ss20', 'p1_tolsu_student_ss20', 'p1_mits_student_ss20',
										'p1_ugrasu_student_ss20')))
	)
				  
SELECT pj.id, ui.untiID, pj.title, 
		 json_unquote(json_extract(pj.data, '$.project_title')) as project_title,  
		 json_unquote(json_extract(pj.data, '$.data.data.card.name')) AS card_name,
		 json_unquote(json_extract(pj.data, '$.data.data.list.name')) AS ListOn,		 
		 json_unquote(json_extract(pj.data, '$.data.data.listBefore.name')) AS ListBefore,
		 json_unquote(json_extract(pj.data, '$.data.data.listAfter.name')) AS ListAfter,	
		 json_unquote(json_extract(pj.data, '$.data.data.card.id')) AS Card_id,	
		 json_unquote(json_extract(pj.data, '$.data.data.card.idShort')) AS Card_Short_id,	
		 json_unquote(json_extract(pj.data, '$.data.display.entities.card.text')) AS card_text,
		 JSON_KEYS(json_extract(pj.data, '$.data.display.entities.card.text')) as keys_list
FROM people.user_info AS ui, people.journal AS pj, const, uid 
WHERE pj.typeid=8 AND pj.userID=ui.userID AND ui.untiID=uid.untiID AND 
		pj.CreateDT>const.begin_date AND pj.CreateDT<const.end_date 
GROUP BY project_title, Card_Short_id, card_name 