SELECT j.teamID, ui.leaderID, ui.untiID, j.title, j.description, j.creatorID, j.CreateDT,
SUBSTRING_INDEX(SUBSTRING_INDEX(JSON_UNQUOTE(JSON_SEARCH(
JSON_EXTRACT(j.data,'$."Оцените значимость вклада участника в развитие проекта на этом этапе, по шкале от 0 до 10 (где 0 - «Участник не сделал ничего для развития проекта», а 10 - «Участник внес самый значимый вклад в развитие проекта»".items')
, 'all', 'true')), ']', 1),'[',-1) AS 'значимость вклада участника',
SUBSTRING_INDEX(SUBSTRING_INDEX(JSON_UNQUOTE(JSON_SEARCH(
JSON_EXTRACT(j.data,'$."Оцените прирост личных компетенций (знаний, умений, навыков) участника за прошедший этап по шкале от 0 о 10 (где 0 - «Участник не приобрел никаких новых компетенций (знаний, умений, навыков)», а 10 - «Участник совершил рывок в личном развитии, освоил совершенно новую деятельность»)".items')
, 'all', 'true')), ']', 1),'[',-1) AS 'прирост личных компетенций',
SUBSTRING_INDEX(SUBSTRING_INDEX(JSON_UNQUOTE(JSON_SEARCH(
JSON_EXTRACT(j.data,'$."Оцените вовлеченность участника в Интенсив по шкале от 0 до 10 (где 0 - «Участник не заинтересован и не погружен в проект», а 10 - «Участник полностью вовлечен в проект и заинтересован в нем на 100%»)".items')
, 'all', 'true')), ']', 1),'[',-1) AS 'вовлеченность участника' 
FROM people.journal AS j 
LEFT JOIN people.user_info AS ui ON ui.userID=j.userID
WHERE j.typeID=23 AND j.createDT > STR_TO_DATE("22 10 2020","%d %m %Y");