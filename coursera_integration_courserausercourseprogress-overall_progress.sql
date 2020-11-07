SELECT * FROM
(
SELECT ui.uid AS untiID, cicp.overall_progress, 
		 JSON_UNQUOTE((json_extract(json_extract(cicp.history, CONCAT('$[', JSON_LENGTH(cicp.history) - 1, ']')), '$.overall_progress'))) AS LAST_progress,
		 JSON_UNQUOTE((json_extract(json_extract(cicp.history, '$[0]'), '$.timestamp'))) as first_stamp_JSON,
		 JSON_UNQUOTE((json_extract(json_extract(cicp.history, '$[0]'), '$.enrolled_at'))) as enrolled_in_JSON,
		 cicp.enrolled_at AS enrolled_in_table, cicp.history
FROM cat.coursera_integration_courserausercourseprogress AS cicp
LEFT JOIN cat.coursera_integration_courserauser AS cic ON  cicp.coursera_user_id = cic.id
LEFT JOIN cat.social_auth_usersocialauth AS ui  ON cic.user_id=ui.user_ID
) AS a
WHERE a.LAST_progress> a.overall_progress;
