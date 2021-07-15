SELECT ui.leaderID, ui.untiID,  c.title AS 'Контекст' , a.text AS 'Цель', 
		 af.rating AS 'Насколько достиг цели', af.text AS 'Почему столько поставил' , af.createDT AS 'Дата оценки' 
FROM now.aim AS a
LEFT JOIN now.user_info AS ui ON ui.userID = a.userID
LEFT JOIN now.context AS c ON a.contextID = c.id
LEFT JOIN now.aim_feedback AS af ON af.aimID = a.id
ORDER BY leaderID, a.id, af.createDT;