SELECT  	ui.leaderID, ui.untiID, ua.`text` AS aim_text , ua.text2 AS aim_text2, ua.createDT AS aim_create_date, 
			aim_hist.text_hist, aim_hist.text2_hist  
from ple.user_aim ua 
left join ple.user_info ui ON ui.userID = ua.userID 
left join (
	select aimID, GROUP_CONCAT(ual.text SEPARATOR ' \n') as text_hist, 
			 GROUP_CONCAT(text2 SEPARATOR ' \n') as text2_hist 
	from ple.user_aim_log ual 
	group by ual.aimID
	) as aim_hist
	ON aim_hist.aimID = ua.id;