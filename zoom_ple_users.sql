SELECT ui.untiID, ui.leaderID, u.email, ui.firstname, ui.lastname, ui.middlename
FROM ple.user AS u, ple.user_info AS ui
WHERE u.id=ui.userID;
