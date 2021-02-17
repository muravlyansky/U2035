WITH const AS 
	  (SELECT   1 as period_id, STR_TO_DATE("01 03 2021","%d %m %Y") AS milestone_start, STR_TO_DATE("28 03 2021","%d %m %Y") AS milestone_end
	   UNION
	   SELECT   2 as period_id, STR_TO_DATE("29 03 2021","%d %m %Y") AS milestone_start, STR_TO_DATE("11 04 2021","%d %m %Y") AS milestone_end
	  ),
	 uid AS 
	 (SELECT  distinct ui.untiID, ui.leaderID, ui.userID  AS ple_userID 
				 FROM ple.user_info  as ui 
				 LEFT JOIN ple.user_tag AS ut ON ut.userID=ui.userID
				 LEFT JOIN ple.tag AS t ON t.id=ut.tagID
				 WHERE ui.untiID IS NOT NULL  AND t.title IN ('p1_ss21_intensive')
		) 

SELECT 	untiID, leaderID, period_id,
		course_enrolled * 1 + course_finished * 5 +  feedback_summ * 1 + artefacts * 2 + 
		focus_count * 5 + lection_req * 5 +	seminar_req * 5 + workshop_req * 5 as 'Образовательная',
		'Запись на Питч-сессию' * 1 + 'Откликов на вакансии' * 2 + cards_created * 1 + 
		cards_moved * 1 + mentor_meeting_req * 1 +	expert_req * 1 + project_protect_req * 1 + 
			hakaton_req * 1 + industry_meeting_req * 1	 as 'Проектная',
		step_count * 5 + collections * 10 + like_count * 1 + project_likes * 1 + 
		favour_count * 1 + disscution_req * 1 as 'Социальная'
FROM (
	SELECT 	uid_const.untiID, uid_const.leaderID, uid_const.period_id,
			IF(Trello_card.create_card_fact IS NOT NULL,Trello_card.create_card_fact,0) AS cards_created,
			IF(Trello_card.move_card_fact IS NOT NULL,Trello_card.move_card_fact,0) AS cards_moved,
			IF(online_course.enrolled IS NOT NULL,online_course.enrolled,0) AS course_enrolled,
			IF(online_course.finished IS NOT NULL,online_course.finished,0) AS course_finished,
			IF(event_req.req_count IS NOT NULL, event_req.req_count,0) AS event_request,
			IF(feedback.feedback_summ IS NOT NULL,feedback.feedback_summ,0) AS feedback_summ,
			IF(cs.footprint IS NOT NULL, cs.footprint,0) AS artefacts,
			IF(focus.focus_count IS NOT NULL,focus.focus_count,0) AS focus_count,
			IF(step_info.step_count IS NOT NULL,step_info.step_count,0) AS step_count,
			IF(step.like_count IS NOT NULL, step.like_count,0) AS like_count,
			IF(step.favour_count IS NOT NULL,step.favour_count,0) AS favour_count,
			IF(step_colection.collections IS NOT NULL, step_colection.collections,0) AS collections,
			IF(projects.project_like  IS NOT NULL,projects.project_like,0) AS project_likes,
			vacancy_respond.vacancy_count AS 'Откликов на вакансии',
			req_user.mentor_meeting_req, 
			req_user.expert_req, 
			req_user.project_protect_req, 
			req_user.hakaton_req, 
			req_user.industry_meeting_req, 
			req_user.lection_req,
			req_user.seminar_req, 
			req_user.workshop_req, 
			req_user.disscution_req, 
			req_user.game_req, 
			req_user.organisation_meeting_req
	
	FROM (SELECT * FROM uid JOIN const) AS uid_const	 				

	LEFT JOIN (	SELECT ui.untiID, SUM(json_unquote(json_extract(pj.data, '$.type'))='createCard') AS create_card_fact, 
					 SUM(json_unquote(json_extract(pj.data, '$.type'))='changeCardStatus') AS move_card_fact,
					 period_id
				  FROM people.user_info AS ui, people.journal AS pj, const 
				  WHERE pj.typeid=8 AND pj.userID=ui.userID AND 
						  pj.CreateDT>const.milestone_start-1  AND pj.CreateDT<=const.milestone_end+1
				  GROUP By pj.userID
				 ) AS Trello_card
	ON Trello_card.untiID=uid_const.untiID 	and Trello_card.period_id=uid_const.period_id

	LEFT JOIN ( SELECT untiID, SUM(finished) AS finished, COUNT(DISTINCT course_id) AS enrolled, period_id
					FROM(
							SELECT ui.uID AS untiID, const.period_id, cus.course_id, (cus.dt_finish IS NOT NULL) AS finished, 0 AS progress
							FROM const,  uid
							LEFT JOIN cat.social_auth_usersocialauth AS ui ON (uid.untiID=ui.uid AND ui.uid IS NOT NULL)
							LEFT JOIN cat.rall_courseuserstatus AS cus ON cus.user_id=ui.user_ID 
							WHERE cus.is_active=1 AND	cus.created_at<=const.milestone_end+1 AND cus.created_at>=const.milestone_start-1
						UNION
							SELECT ui.uID AS untiID, const.period_id, cicp.course_id, cicp.is_completed AS finished, cicp.overall_progress AS progress 
							FROM const,  uid
							LEFT JOIN cat.social_auth_usersocialauth AS ui ON (uid.untiID=ui.uid AND ui.uid IS NOT NULL)
							LEFT JOIN cat.coursera_integration_courserauser AS cic ON cic.user_id=ui.user_ID 
							LEFT JOIN cat.coursera_integration_courserausercourseprogress AS cicp ON cicp.coursera_user_id = cic.id
							WHERE (JSON_UNQUOTE((json_extract(json_extract(cicp.history, '$[0]'), '$.timestamp')))<=const.milestone_end+1) AND
								  (JSON_UNQUOTE((json_extract(json_extract(cicp.history, '$[0]'), '$.timestamp')))>=const.milestone_start-1)
						UNION
							SELECT au.username AS untiID, cs.course_id, const.period_id, 0 AS finished, 
							MAX(JSON_UNQUOTE((JSON_EXTRACT(cs.state, '$.position'))))*5 + SUM(cs.grade) AS progress 
							FROM  const,  uid
							LEFT JOIN edx_edx.auth_user AS au ON au.username = uid.untiID
							LEFT JOIN edx_edx.courseware_studentmodule AS cs ON au.id = cs.student_id
							WHERE module_type IN ('problem','chapter') AND cs.created>=const.milestone_start-1 AND cs.created <=const.milestone_end+1
							GROUP BY course_id, au.username
					) AS courses
					GROUP BY untiID, period_id
				 ) AS online_course
	ON online_course.untiID=uid_const.untiID  and online_course.period_id=uid_const.period_id

	LEFT JOIN (SELECT  ui.untiID, COUNT(uar.id) AS req_count, period_id
				FROM  const,  labs.activity AS a
				left join labs.context_activity ca on ca.activityID = a.id 
				left join labs.run r on r.activityID = a.id
				left JOIN labs.user_activity_request uar on uar.runID=r.id 
				left JOIN labs.user_info as ui ON ui.userID=uar.userID AND ui.untiID IS NOT Null
				WHERE ca.contextID=285 AND
					   uar.createDT>const.milestone_start-1  AND uar.createDT<=const.milestone_end+1
				GROUP BY ui.userID
					) AS event_req
	ON event_req.untiID=uid_const.untiID and event_req.period_id=uid_const.period_id

	LEFT JOIN (	SELECT untiID, COUNT(ufa.id) AS feedback_summ, period_id					
				FROM	const, labs.user_feedback_answer AS ufa
				LEFT JOIN labs.feedback_question AS fq ON fq.id=ufa.feedbackQuestionID
				LEFT JOIN (	SELECT fq1.feedbackFormID, COUNT(fq1.id) AS fq_all 
							FROM  labs.feedback_question AS fq1 GROUP BY  fq1.feedbackFormID 
						) AS ff	  ON ff.feedbackFormID=fq.feedbackFormID
				LEFT JOIN labs.event e ON e.id=ufa.eventID	
				left join labs.run r on r.id = e.runID
				left JOIN labs.activity a on a.id=r.activityID
				left join labs.context_activity ca on ca.activityID = a.id
				left JOIN labs.user_info as ui ON ufa.userID=ui.userID AND ui.untiID IS NOT NULL 
				WHERE 	ca.contextID=285  AND 
						ufa.createDT>const.milestone_start  AND ufa.createDT<=const.milestone_end+1
				GROUP BY ui.untiID			
				) AS feedback
	ON feedback.untiID=uid_const.untiID and feedback.period_id=uid_const.period_id


	LEFT JOIN ( SELECT iu.unti_id AS untiID, COUNT(iem.id) AS footprint, const.period_id AS period_id 
				FROM const, isle.isle_eventmaterial iem 
				LEFT JOIN isle.isle_user iu ON iu.id=iem.user_id
				LEFT JOIN isle.isle_event ise on ise.id=iem.event_id
				WHERE  iem.created_at>const.milestone_start  AND iem.created_at<=const.milestone_end+1
				GROUP BY iu.unti_id 
				) as cs
	ON cs.untiID = uid_const.untiID and cs.period_id=uid_const.period_id


	LEFT JOIN ( SELECT sc.untiID, COUNT(distinct title) AS focus_count, const.period_id AS period_id
				   FROM const, ple.step_collection AS sc 
					WHERE TYPE='focus' AND sc.createDT>const.milestone_start-1  AND sc.createDT<=const.milestone_end+1
					GROUP BY sc.untiID
	) AS focus
	ON	focus.untiID = uid_const.untiID and focus.period_id=uid_const.period_id

	LEFT JOIN ( SELECT ss.untiID, SUM(ss.url IS NOT NULL) AS url_count, SUM(sst.tool_count) AS tool_count,
					   COUNT(DISTINCT ss.uuid) AS step_count, COUNT(ss.url IS NOT NULL AND tool_count ) AS step_full, 
					   const.period_id AS period_id
					FROM const, ple.step_step AS ss
					LEFT JOIN (SELECT if(count(toolTitle)>0,1,0) AS tool_count, stepUuid  
								  from ple.step_step_tool 
								  GROUP BY  stepUuid) AS sst
								  ON sst.stepUuid=ss.uuid
					WHERE ss.createDT>const.milestone_start-1  AND ss.createDT<=const.milestone_end+1
					GROUP BY ss.untiID
				 ) AS step_info
	ON	step_info.untiID = uid_const.untiID and step_info.period_id=uid_const.period_id

	LEFT JOIN( SELECT untiID, SUM(collection_length) AS collections, period_id
				  FROM (
							SELECT scg.untiID, scg.uuid, IF(COUNT(distinct sco.description)>2,1,0) AS collection_length, const.period_id AS period_id
							FROM const, ple.step_collection_group as scg
							LEFT JOIN ple.step_collection_object AS sco ON   sco.collectionGroupUuid=scg.uuid
							WHERE sco.createDT >const.milestone_start-1  AND sco.createDT<=const.milestone_end+1
							GROUP BY scg.untiID, scg.uuid
							) AS sc
					GROUP BY untiID
				) AS step_colection		  
	ON	step_colection.untiID = uid_const.untiID and step_colection.period_id=uid_const.period_id
				  
	LEFT JOIN ( SELECT untiID, SUM(step_action='likes') AS like_count, SUM(step_action='favour') AS favour_count, period_id
				FROM (	SELECT untiID, IF(type IN ('like','dislike','rating'), 'likes', 'favour') AS step_action, const.period_id AS period_id
						FROM const, ple.step_user_tracker_log AS sutl 
						WHERE sutl.type IN ('like','dislike','rating','favourite','unfavourite') AND
							  sutl.createDT>const.milestone_start-1  AND sutl.createDT<=const.milestone_end+1
					 ) AS sutl
				GROUP BY untiID
				) as step
	ON	step.untiID = uid_const.untiID and step.period_id=uid_const.period_id

	LEFT JOIN ( SELECT untiID, SUM(project_like) AS project_like, period_id  
					FROM (
							SELECT ui.untiID, count(pr.id) AS project_like, const.period_id
							FROM  const, uid
							LEFT JOIN people.user_info AS ui ON ui.untiID=uid.untiID AND ui.untiID IS NOT null
							LEFT JOIN people.project_rating AS pr ON pr.userID=ui.untiID 
							WHERE pr.createDT>const.milestone_start-1  AND pr.createDT<=const.milestone_end+1
						UNION
							SELECT ui.untiID, count(pul.productID) AS project_like, const.period_id
							FROM  const, uid
							LEFT JOIN edumap.user_info AS ui ON ui.untiID=uid.untiID AND ui.untiID IS NOT null
							LEFT JOIN edumap.product_user_like AS pul ON pul.userID=ui.untiID 
							WHERE pul.createDT>const.milestone_start-1  AND pul.createDT<=const.milestone_end+1
						) AS likes
						GROUP BY untiID
					) AS projects
	ON	projects.untiID = uid_const.untiID and projects.period_id=uid_const.period_id

	LEFT JOIN (			
				SELECT  	ui.leaderID, const.period_id, 
							SUM(at.typeID=1124) AS mentor_meeting_req, 
							SUM(at.typeID=1127) AS expert_req, 
							SUM(at.typeID=1126) AS project_protect_req, 
							SUM(at.typeID=1129) AS hakaton_req, 
							SUM(at.typeID=1128) AS industry_meeting_req, 
							SUM(at.typeID=1125) AS lection_req,
							SUM(at.typeID=1136) AS seminar_req, 
							SUM(at.typeID=1134) AS workshop_req, 
							SUM(at.typeID=1138) AS disscution_req, 
							SUM(at.typeID=1139) AS game_req, 
							SUM(at.typeID=1137) AS organisation_meeting_req							
				FROM  const, labs.user_activity_request uar
				LEFT JOIN labs.run r ON uar.runID=r.id 
				LEFT JOIN labs.activity AS a ON r.activityID = a.id
				LEFT JOIN labs.activity_type at ON a.id = at.activityID  
				LEFT JOIN labs.context_activity ca on ca.activityID = a.id 
				LEFT JOIN labs.event e ON e.runID=r.id
				LEFT JOIN labs.timeslot AS ts ON ts.id=e.timeslotID
				LEFT JOIN labs.user_info as ui ON ui.userID=uar.userID 
				WHERE ca.contextID=285 AND at.typeID IN (1124,1127,1126,1129,1128,1125,1136,1134,1138,1139,1137) AND 
					  ts.startDT>=const.milestone_start-1 AND ts.startDT<const.milestone_end+1
				GROUP BY ui.leaderID, const.period_id
			) AS req_user
			ON req_user.leaderID=uid_const.leaderID	AND req_user.period_id=uid_const.period_id
	LEFT JOIN (
					SELECT ui.leaderID, const.period_id, COUNT(pvr.vacancyID) AS vacancy_count
					FROM people.project_vacancy_respond AS pvr 
					JOIN const
					LEFT JOIN people.user_info AS ui ON pvr.userID=ui.userID AND ui.leaderID IS NOT null
					WHERE pvr.createDT>=const.milestone_start-1 AND pvr.createDT<const.milestone_end+1
					GROUP BY ui.leaderID, const.period_id
				) AS 	vacancy_respond
			ON vacancy_respond.leaderID=uid_const.leaderID	AND vacancy_respond.period_id=uid_const.period_id
	) as raw_engagement
;