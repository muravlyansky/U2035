# 
WITH const AS  (SELECT  '$.initiator' AS tag_str,
	  			  				'$.data.data.board.id' AS tag_str_1,
	  			  				'$.data.data.board.name' AS tag_str_2	  			  
	  				),
	  uid AS (SELECT distinct ui.untiID, ui.leaderID, ui.userID  AS ple_userID, t.title AS VUZ_tag 
				 FROM ple.user_info  as ui 
				 LEFT JOIN ple.user_tag AS ut ON ut.userID=ui.userID
				 LEFT JOIN ple.tag AS t ON t.id=ut.tagID
				 WHERE t.title in ('p1_ncfu_student_ss20', 'p1_sevsu_student_ss20', 'p1_vyatsu_student_ss20',
						'p1_rsue_student_ss20', 'p1_chuvsu_student_ss20', 'p1_sfu_student_ss20',
						'p1_vstu_student_ss20', 'p1_tolsu_student_ss20', 'p1_mits_student_ss20',
						'p1_ugrasu_student_ss20')
	)	  
SELECT initiator, COUNT(board), uid.leaderID, GROUP_CONCAT(board_name) AS board_list, uid.VUZ_tag 
FROM uid
LEFT JOIN (
	SELECT 
			 json_unquote(json_extract(pj.data, tag_str )) AS initiator,
	 		 json_unquote(json_extract(pj.data, tag_str_1 )) AS board,
	 		 json_unquote(json_extract(pj.data, tag_str_2 )) AS board_name
	FROM people.journal AS pj, const 
	WHERE pj.typeid=8  
	GROUP BY initiator, board) AS user_boards
ON user_boards.initiator=uid.untiID
GROUP BY initiator
HAVING COUNT(board)>1			;
