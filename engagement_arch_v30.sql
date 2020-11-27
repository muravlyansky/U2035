WITH const AS 
	  ( SELECT   1 AS day_id, STR_TO_DATE("07 11 2020","%d %m %Y") AS day_n UNION
		SELECT   2 AS day_id, STR_TO_DATE("08 11 2020","%d %m %Y") AS day_n	UNION
		SELECT   3 AS day_id, STR_TO_DATE("09 11 2020","%d %m %Y") AS day_n	UNION
		SELECT   4 AS day_id, STR_TO_DATE("10 11 2020","%d %m %Y") AS day_n	UNION
		SELECT   5 AS day_id, STR_TO_DATE("11 11 2020","%d %m %Y") AS day_n	UNION
		SELECT   6 AS day_id, STR_TO_DATE("12 11 2020","%d %m %Y") AS day_n	UNION
		SELECT   7 AS day_id, STR_TO_DATE("13 11 2020","%d %m %Y") AS day_n	UNION
		SELECT   8 AS day_id, STR_TO_DATE("14 11 2020","%d %m %Y") AS day_n	UNION
		SELECT   9 AS day_id, STR_TO_DATE("15 11 2020","%d %m %Y") AS day_n	UNION
		SELECT  10 AS day_id, STR_TO_DATE("16 11 2020","%d %m %Y") AS day_n	UNION
		SELECT  11 AS day_id, STR_TO_DATE("17 11 2020","%d %m %Y") AS day_n	UNION
		SELECT  12 AS day_id, STR_TO_DATE("18 11 2020","%d %m %Y") AS day_n	UNION
		SELECT  13 AS day_id, STR_TO_DATE("19 11 2020","%d %m %Y") AS day_n	UNION
		SELECT  14 AS day_id, STR_TO_DATE("20 11 2020","%d %m %Y") AS day_n	UNION
		SELECT  15 AS day_id, STR_TO_DATE("21 11 2020","%d %m %Y") AS day_n		
	  )
SELECT 	ui.leaderID, const.day_n AS 'День',
			project_presentation_user.presentations AS 'Загружена в PT презентация по проекту',
			project_tags_user.project_marked AS 'Проект в ПТ размечен', 
			task_edu_user.Tasks_Created AS 'Участником создана задача в Командном профиле', 
			task_edu_user.Tasks_Done AS 'Выполнена задача в ком.профиле', 
			task_edu_user.Tasks_Validated AS 'Верифицировано решение в ком.профиле', 
			task_edu_user.EDUreq_Created AS 'Создание Темы изучения в Ком.профиле', 
			task_edu_user.EDUreq_Done AS 'Закрыта Тема изучения в Ком.профиле',
			req_user.axeleration_req AS 'Запись на Акслератор', 
			req_user.expert_req AS 'Запись на встречу с экспертом', 
			req_user.lab_req AS 'Запись на Лабораторию', 
			req_user.workshop_req AS 'Запись на МК',  
			req_user.effic_req AS 'Запись на повышение эффективности', 
			req_user.pitch_req AS 'Запись на Питч-сессию',
			aim_change.aim_changes AS 'Отредактирована цель', 
			aim_fb.aim_feedbacks AS 'Оценено продвижение к цели в ЛК', 
			event_fb.event_feedbacks AS 'Оставлен Фидбек на мероприятие (хотя бы один ответ)',
			products.products AS 'Создан Продукт в Edumap',
			project_like.project_like AS 'Поставлен лайк проекту в ПТ',
			product_like.product_like AS 'Поставлен лайк продукту (карточке) в Edumap',
			vacancy_created.vacancy_count AS 'Создано вакансий',
			vacancy_respond.vacancy_count AS 'Откликов на вакансии',
			payed_list.payed AS 'Оплативший участие',
			arch_team.team_project AS 'Название проекта'
FROM  labs.user_info AS ui 
JOIN const
LEFT JOIN ( 
			SELECT leaderID, COUNT(p_id) AS projects, SUM(presentations) AS presentations, const.day_n
			FROM const,
					(	SELECT ui.leaderID, p.id AS p_id, p.title, count(distinct pp.id) AS presentations, pp.createDT
						FROM people.project AS p 
						LEFT JOIN people.project_presentation AS pp ON pp.projectID=p.id
						LEFT JOIN people.project_team AS prt ON prt.projectID=p.id
						LEFT JOIN people.team AS t ON prt.teamID=t.id
						LEFT JOIN people.team_user AS tu ON tu.teamID=prt.teamID
						LEFT JOIN people.user_info AS ui ON ui.userID=tu.userID
						WHERE ui.leaderID IS NOT NULL
						GROUP BY ui.leaderID, p.id, pp.createDT
					) AS project_presentation_by_project_user
			WHERE project_presentation_by_project_user.createDT>=const.day_n AND  project_presentation_by_project_user.createDT<const.day_n+1
			GROUP BY leaderID, const.day_n
			) as project_presentation_user
		ON project_presentation_user.leaderID=ui.leaderID AND project_presentation_user.day_n=const.day_n
LEFT JOIN (
				SELECT leaderID, day_n, IF(market>0 OR method>0 OR tech>0 OR task>0,1,0) AS project_marked
				FROM (
								SELECT  ui.leaderID, const.day_n, p.id AS p_id,
								SUM(pt.type='market') AS market,	SUM(pt.type='method') AS method,	SUM(pt.type='tech') AS tech, SUM(pt.type='task') AS task
								FROM const, people.project AS p
								LEFT JOIN people.project_tag AS pt ON pt.projectID=p.id
								LEFT JOIN people.project_team AS prt ON prt.projectID=p.id
								LEFT JOIN people.team AS t ON prt.teamID=t.id
								LEFT JOIN people.team_user AS tu ON tu.teamID=prt.teamID
								LEFT JOIN people.user_info AS ui ON ui.userID=tu.userID
								WHERE ui.leaderID IS NOT NULL AND pt.createDT>=const.day_n AND  pt.createDT<const.day_n+1
								GROUP BY ui.leaderID,  const.day_n, p.id
						) AS projects_marked
				GROUP BY leaderID,  day_n
			) AS  project_tags_user
		ON project_tags_user.leaderID=ui.leaderID	 AND project_tags_user.day_n=const.day_n
LEFT JOIN (	
			SELECT sc.untiID , const.day_n, sc.createDT,sc.dt,
						SUM(sc.status='new' AND sc.type ='task_team') AS Tasks_Created,  
						SUM(sc.status='done' AND sc.type ='task_team' AND scaf.url IS NOT NULL) AS Tasks_Done,				 
						SUM(sc.status='validated' AND sc.type ='task_team') AS Tasks_Validated, 
						SUM(sc.status='validated_error' AND sc.type ='task_team') AS Tasks_Validated_error,
						SUM(sc.status='new' AND sc.type ='focus_team') AS EDUreq_Created,  
						SUM(sc.status='done' AND sc.type ='focus_team') AS EDUreq_Done
				FROM const, ple.step_collection sc
				LEFT JOIN ple.step_collection_artefact AS sca ON  sca.collectionUuid=sc.uuid
				LEFT JOIN ple.step_collection_artefact_files AS scaf ON scaf.artefactID=sca.uuid
				WHERE sc.untiID IS NOT NULL and sc.type IN ('task_team','focus_team') AND IF(sc.dt IS NOT NULL, sc.dt, sc.createDT)>=const.day_n AND IF(sc.dt IS NOT NULL, sc.dt, sc.createDT)<const.day_n+1 
				GROUP BY sc.untiID, const.day_n
				) AS  task_edu_user
		ON task_edu_user.untiID=ui.untiID	AND task_edu_user.day_n=const.day_n
LEFT JOIN (			
				SELECT  	ui.leaderID, const.day_n, SUM(at.typeID=1146) AS axeleration_req, SUM(at.typeID=1147) AS expert_req, SUM(at.typeID=1149) AS lab_req, 
							SUM(at.typeID=1148) AS workshop_req, SUM(at.typeID=1164) AS effic_req, SUM(at.typeID=1151) AS pitch_req
				FROM  const, labs.user_activity_request uar
				LEFT JOIN labs.run r ON uar.runID=r.id 
				LEFT JOIN labs.activity AS a ON r.activityID = a.id
				LEFT JOIN labs.activity_type at ON a.id = at.activityID  
		      LEFT JOIN labs.context_activity ca on ca.activityID = a.id 
 		      LEFT JOIN labs.event e ON e.runID=r.id
		      LEFT JOIN labs.timeslot AS ts ON ts.id=e.timeslotID
         	LEFT JOIN labs.user_info as ui ON ui.userID=uar.userID 
				WHERE ca.contextID=355 AND at.typeID IN (1146,1147,1148,1149,1164,1151) AND ts.startDT>=const.day_n AND ts.startDT<const.day_n+1 
				GROUP BY ui.leaderID, const.day_n
			) AS req_user
		ON req_user.leaderID=ui.leaderID	AND req_user.day_n=const.day_n
LEFT JOIN (
				SELECT ui.leaderID, const.day_n, COUNT(DISTINCT al.text) AS aim_changes
				FROM now.aim_log al 
				JOIN const
				LEFT JOIN now.aim a ON a.id=al.aimID
				LEFT JOIN now.user_info AS ui ON al.userID=ui.userID AND ui.leaderID IS NOT null
				WHERE al.createDT>=const.day_n AND al.createDT<const.day_n+1 
				GROUP BY ui.leaderID, const.day_n
			 ) AS aim_change
		ON aim_change.leaderID=ui.leaderID	AND aim_change.day_n=const.day_n		

LEFT JOIN (
				SELECT ui.leaderID, const.day_n, IF(COUNT(af.rating) IS NOT NULL,1,0) AS aim_feedbacks
				FROM now.aim_feedback af 
				JOIN const
				LEFT JOIN now.aim a ON a.id=af.aimID
				LEFT JOIN now.user_info AS ui ON a.userID=ui.userID AND ui.leaderID IS NOT null
				WHERE af.createDT>=const.day_n AND af.createDT<const.day_n+1 
				GROUP BY ui.leaderID, const.day_n
			) AS aim_fb
		ON aim_fb.leaderID=ui.leaderID	AND aim_fb.day_n=const.day_n	
LEFT JOIN (
				SELECT leaderID, day_n, SUM(event_feedbacks) AS event_feedbacks
				FROM(
						SELECT ui.leaderID, const.day_n, IF(count(ufa.id) IS NOT NULL,1,0) AS event_feedbacks, ufa.eventID
						FROM labs.user_feedback_answer AS ufa 
						JOIN const
						LEFT JOIN labs.user_info AS ui ON ufa.userID=ui.userID AND ui.leaderID IS NOT null
						WHERE ufa.createDT>=const.day_n AND ufa.createDT<const.day_n+1 
						GROUP BY ui.leaderID, const.day_n, ufa.eventID
					) AS feedback_by_event
				GROUP BY leaderID, day_n
			) AS  event_fb
		ON event_fb.leaderID=ui.leaderID	AND event_fb.day_n=const.day_n			
LEFT JOIN (
				SELECT ui.leaderID, const.day_n, COUNT(p.uuid) AS products
				FROM edumap.product AS p 
				JOIN const
				LEFT JOIN edumap.user_info AS ui ON p.userID=ui.userID AND ui.leaderID IS NOT null
				WHERE p.createDT>=const.day_n AND p.createDT<const.day_n+1 
				GROUP BY ui.leaderID, const.day_n
			 ) AS products
		ON products.leaderID=ui.leaderID	AND products.day_n=const.day_n					
LEFT JOIN (
				SELECT ui.leaderID, const.day_n, COUNT(pr.id) AS project_like
				FROM people.project_rating AS pr 
				JOIN const
				LEFT JOIN people.user_info AS ui ON pr.userID=ui.userID AND ui.leaderID IS NOT null
				WHERE pr.createDT>=const.day_n AND pr.createDT<const.day_n+1 
				GROUP BY ui.leaderID, const.day_n
			 ) AS project_like
		ON project_like.leaderID=ui.leaderID	AND project_like.day_n=const.day_n		
LEFT JOIN (
				SELECT ui.leaderID, const.day_n, COUNT(pur.createDT) AS product_like
				FROM edumap.product_user_like AS pur 
				JOIN const
				LEFT JOIN edumap.user_info AS ui ON pur.userID=ui.userID AND ui.leaderID IS NOT null
				WHERE pur.createDT>=const.day_n AND pur.createDT<const.day_n+1 
				GROUP BY ui.leaderID, const.day_n
			 ) AS product_like		
		ON product_like.leaderID=ui.leaderID	AND product_like.day_n=const.day_n	
LEFT JOIN (
				SELECT ui.leaderID, const.day_n, COUNT(pvr.vacancyID) AS vacancy_count
				FROM people.project_vacancy_respond AS pvr 
				JOIN const
				LEFT JOIN people.user_info AS ui ON pvr.userID=ui.userID AND ui.leaderID IS NOT null
				WHERE pvr.createDT>=const.day_n AND pvr.createDT<const.day_n+1 
				GROUP BY ui.leaderID, const.day_n
			) AS 		vacancy_respond
		ON vacancy_respond.leaderID=ui.leaderID	AND vacancy_respond.day_n=const.day_n	
LEFT JOIN (
				SELECT ui.leaderID, const.day_n, SUM(pv.active) - SUM(pv.isDeleted) AS vacancy_count
				FROM people.project_vacancy AS pv 
				JOIN const
				LEFT JOIN people.project_team AS pt ON pt.projectID=pv.projectID
				LEFT JOIN people.team_user AS tu ON tu.teamID=pt.teamID
				LEFT JOIN people.user_info AS ui ON tu.userID=ui.userID AND ui.leaderID IS NOT null
				WHERE pv.createDT>=const.day_n AND pv.createDT<const.day_n+1 AND tu.role='leader' 
				GROUP BY ui.leaderID, const.day_n) AS vacancy_created		
		ON vacancy_created.leaderID=ui.leaderID	AND vacancy_created.day_n=const.day_n
LEFT JOIN ( SELECT ui.leaderID, IF(SUM(t.guid = 'arch2035_payment_success')>0,1,0) AS payed
				FROM ple.user_info AS ui
				left JOIN ple.user_tag ut on ut.userid = ui.userid
				left join ple.tag t on t.id = ut.tagid
				where t.guid = "arch2035_payment_success" AND ui.leaderid IS NOT NULL
				GROUP BY ui.leaderID					
			) AS payed_list
		ON payed_list.leaderID=ui.leaderID	
LEFT JOIN (
				SELECT ui.leaderID,ui.untiID, p.title AS team_project
				FROM people.user_info AS ui
				LEFT JOIN people.team_user AS tu ON ui.userID=tu.userID
				LEFT JOIN people.team AS t ON t.id=tu.teamID
				LEFT JOIN people.project_team AS pt ON pt.teamID=tu.teamID
				LEFT JOIN people.project AS p ON p.id=pt.projectID 
				WHERE p.guid LIKE 'project-%' AND ui.leaderID IS NOT NULL AND ui.untiID IS NOT NULL
				GROUP BY  ui.leaderID, p.id
			) AS arch_team
		ON arch_team.leaderID=ui.leaderID					
																			
WHERE ui.leaderID in
( SELECT DISTINCT 	leaderid 
	FROM(
		Select distinct ui.leaderID AS leaderid from ple.user_info ui
		left JOIN ple.user_tag ut on ut.userid = ui.userid
		left join ple.tag t on t.id = ut.tagid
		where t.guid = "arch2035_payment_success" AND ui.leaderid IS NOT NULL
			UNION
		SELECT distinct user AS leaderID FROM prd_analytics.users
			UNION
		Select distinct ui.leaderid AS leaderID from ple.user_info ui
		left join ple.user_tag ut on ut.userid = ui.userid
		left join ple.tag t on t.id = ut.tagid
		WHERE  t.guid IN ( 'p0_student_ss20', 'p1_aw20_student')
	) AS list
)
GROUP BY ui.leaderID, const.day_n
ORDER BY ui.leaderID, const.day_n;
