SELECT  tutor_team.teamID,  presentations, market , method, tech, task,
		create_card_facts, move_card_facts, mentor_meeting_reqs, 
		expert_reqs, project_protect_reqs, hakaton_reqs, industry_meeting_reqs		
FROM (
		select tu.userID, tu.teamID 
		from people.team_user tu 
		left join people.context_team ct  on ct.teamID = tu.teamID 
		left join people.context c on c.id = ct.contextID 
		where tu.role ='tutor' and c.guid = 'edunetwork'
		group by tu.userID, tu.teamID 
	 ) as tutor_team
LEFT JOIN (		
		SELECT prt.teamID, count(pp.id) AS presentations
		FROM people.project_presentation AS pp  
		LEFT JOIN people.project AS p ON pp.projectID=p.id
		LEFT JOIN people.project_team AS prt ON prt.projectID=p.id
		GROUP BY prt.teamID
		) as team_pres ON team_pres.teamID = tutor_team.teamID
LEFT JOIN (
		SELECT  prt.teamID,	SUM(pt.type='market') AS market,	SUM(pt.type='method') AS method,	SUM(pt.type='tech') AS tech, SUM(pt.type='task') AS task
		FROM people.project AS p
		LEFT JOIN people.project_tag AS pt ON pt.projectID=p.id
		LEFT JOIN people.project_team AS prt ON prt.projectID=p.id
		GROUP BY prt.teamID 
		) as project_tag ON project_tag.teamID = tutor_team.teamID
LEFT JOIN (
		SELECT 	team_lid.teamID, SUM(create_card_fact) as  create_card_facts, SUM(move_card_fact) as move_card_facts, SUM(mentor_meeting_req) as mentor_meeting_reqs, 
				SUM(expert_req) as expert_reqs, SUM(project_protect_req) as project_protect_reqs, SUM(hakaton_req) as hakaton_reqs, SUM(industry_meeting_req) as industry_meeting_reqs
		FROM (
				SELECT ui.leaderID, tu2.teamID 
				FROM people.team t 
				LEFT JOIN people.team_user tu2 ON tu2.teamID = t.id 
				LEFT JOIN people.user_info ui ON ui.userID = tu2.userID and ui.leaderID  is not null
				WHERE tu2.role <> 'tutor'
			) as team_lid
		
		LEFT JOIN (	
				SELECT 	ui.leaderID, SUM(json_unquote(json_extract(pj.data, '$.type'))='createCard') AS create_card_fact, 
						SUM(json_unquote(json_extract(pj.data, '$.type'))='changeCardStatus') AS move_card_fact
				FROM 	people.journal AS pj
				LEFT JOIN people.user_info as ui ON ui.userID=pj.userID and ui.leaderID  is not null
				WHERE 	pj.typeid=8 
				GROUP By pj.userID
						 ) AS Trello_card ON Trello_card.leaderID = team_lid.leaderID	
		LEFT JOIN (			
				SELECT  ui.leaderID, 
						SUM(at.typeID=1124) AS mentor_meeting_req, 
						SUM(at.typeID=1127) AS expert_req, 
						SUM(at.typeID=1126) AS project_protect_req, 
						SUM(at.typeID=1129) AS hakaton_req, 
						SUM(at.typeID=1128) AS industry_meeting_req 
				FROM  	labs.user_activity_request uar
				LEFT JOIN labs.run r ON uar.runID=r.id 
				LEFT JOIN labs.activity AS a ON r.activityID = a.id
				LEFT JOIN labs.activity_type at ON a.id = at.activityID  
				LEFT JOIN labs.context_activity ca on ca.activityID = a.id
				LEFT JOIN labs.context c on ca.contextID  = c.id 
				LEFT JOIN labs.event e ON e.runID=r.id
				LEFT JOIN labs.timeslot AS ts ON ts.id=e.timeslotID
				LEFT JOIN labs.user_info as ui ON ui.userID=uar.userID and ui.leaderID  is not null
				WHERE c.guid = 'edunetwork' AND at.typeID IN (1124,1127,1126,1129,1128,1125,1136,1134,1138,1139,1137)
				GROUP BY ui.leaderID
					) AS req_user ON req_user.leaderID = team_lid.leaderID	
		GROUP BY team_lid.teamID
		) as team_agg ON team_agg.teamID = tutor_team.teamID