WITH uid AS 
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
SELECT uid.untiID, COUNT(DISTINCT projectID) AS pr_count 
FROM people.project_rating AS pr, people.user_info AS ui, uid
WHERE uid.untiID=ui.untiID AND pr.userID=ui.userID
GROUP BY uid.untiID
ORDER BY pr_count desc;		
