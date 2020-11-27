WITH uid as (	SELECT ui.untiID
					FROM people.team_user AS tu
					LEFT JOIN people.team AS t ON tu.teamID=t.id
					LEFT JOIN people.user_info AS ui ON tu.userID=ui.userID
					LEFT JOIN people.context_team AS ct ON t.id=ct.teamID
					WHERE ct.contextID IN (386,287,245,127,111,112,113,114,117,115,139,120,121,141,123,124,152,125,153,129,108,109,132,110,116,161,26,45,46,27,47,44,31,49,51,52,30,55,118,119)
							AND tu.role IN('member','leader','redactor') 
							AND (ui.jobCompanyTitle NOT IN('Университет НТИ "20.35"','АНО «Университет 2035»') OR ui.jobCompanyTitle IS NULL)
					GROUP BY ui.untiID
					HAVING count(distinct ct.contextID)>1 
		) 
SELECT 	team_list AS teamID_list, GROUP_CONCAT(distinct uid_untiID) AS untiID_list	
FROM (		
		SELECT uid.untiID AS uid_untiID, ui.untiID, count(distinct tu.teamID) AS count_teams, count(distinct ct.contextID) AS count_context, 
				 GROUP_CONCAT(distinct tu.teamID) AS team_list
		FROM uid, people.team_user AS tu
		LEFT JOIN people.user_info AS ui ON tu.userID=ui.userID
		LEFT JOIN people.team AS t ON tu.teamID=t.id
		LEFT JOIN people.context_team AS ct ON t.id=ct.teamID
		WHERE tu.teamID IN (
			SELECT t.id AS teamID
			FROM people.team_user AS tu
			LEFT JOIN people.team AS t ON tu.teamID=t.id
			LEFT JOIN people.user_info AS ui ON tu.userID=ui.userID
			LEFT JOIN people.context_team AS ct ON t.id=ct.teamID
			WHERE ct.contextID IN (386,287,245,127,111,112,113,114,117,115,139,120,121,141,123,124,152,125,153,129,108,109,132,110,116,161,26,45,46,27,47,44,31,49,51,52,30,55,118,119) 
					AND tu.role IN('member','leader','redactor')
					AND ui.untiID=uid.untiID 
			) AND ui.untiID<>uid.untiID AND tu.role IN('member','leader','redactor')
		GROUP BY ui.untiID, uid_untiID
		HAVING count_context>1
	  ) AS teams_list
GROUP BY teamID_list;
