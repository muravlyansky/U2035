#Список прошедших отбор на Архипелаг по условиям STEP команд

SELECT project.guid,  COUNT(project.untiID) AS team_count, SUM(step_full>2) AS people_pasted, SUM(step_text>2) AS people_tried
FROM (SELECT ui.untiID, t.title AS team_title, p.title AS project_title, p.guid
		FROM people.project p, people.user_info ui, people.team_user tu , people.team  t, people.project_team pt 
		WHERE p.guid LIKE 'project-%' AND p.createDT>STR_TO_DATE("01 10 2020","%d %m %Y") and
			pt.projectID = p.id and
			pt.teamID = t.id and
			t.id=tu.teamID and
			tu.userID = ui.userID
		GROUP BY ui.untiID,  p.guid) AS project
		
LEFT JOIN (SELECT ss.untiID, SUM( LENGTH(ss.text)>0 AND tool_count ) AS step_full, SUM( LENGTH(ss.text)>0) AS step_text
				FROM ple.step_step AS ss
				LEFT JOIN (SELECT if(count(toolTitle)>0,1,0) AS tool_count, stepUuid  
							  from ple.step_step_tool 
							  GROUP BY  stepUuid) AS sst
							  ON sst.stepUuid=ss.uuid
				WHERE ss.createDT>STR_TO_DATE("01 10 2020","%d %m %Y")  
				GROUP BY ss.untiID) AS step
	ON step.untiID=project.untiID
GROUP BY project.guid
ORDER BY people_pasted DESC, people_tried DESC;
