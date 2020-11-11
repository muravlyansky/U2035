
WITH const AS 
	  (SELECT   1 as period_id, STR_TO_DATE("15 09 2020","%d %m %Y") AS milestone_start, STR_TO_DATE("16 10 2020","%d %m %Y") AS milestone_end 
	  ),
	  uid AS (SELECT  distinct ui.untiID, ui.leaderID, ui.userID  AS ple_userID, 
							t.title AS VUZ_tag 
				 FROM ple.user_info  as ui 
				 LEFT JOIN ple.user_tag AS ut ON ut.userID=ui.userID
				 LEFT JOIN ple.tag AS t ON t.id=ut.tagID
				 WHERE t.title in 
				 ('p1_aw20_amursu_student', 'p1_aw20_asau_student',    'p1_aw20_bsau_student',   'p1_aw20_chuvsau_student','p1_aw20_chuvsu_student',
				  'p1_aw20_donstu_student', 'p1_aw20_dvfu_student',    'p1_aw20_itmo_student',   'p1_aw20_ivgsha_student', 'p1_aw20_kgsha_student',
				  'p1_aw20_ksai_student',   'p1_aw20_ksu_edu_student', 'p1_aw20_kubsau_student', 'p1_aw20_leti_student',   'p1_aw20_mgau_student',
				  'p1_aw20_midis_student',  'p1_aw20_mitumasi_student','p1_aw20_ncfu_student',   'p1_aw20_ngma_student',   'p1_aw20_nsau_edu_student',
				  'p1_aw20_omgau_student',  'p1_aw20_orelsau_student', 'p1_aw20_osu_student',	 'p1_aw20_penzgau_student','p1_aw20_pgsha_student',
				  'p1_aw20_pgusa_student',  'p1_aw20_psuti_student',   'p1_aw20_rgatu_student',  'p1_aw20_rsue_student',   'p1_aw20_samgau_student',
				  'p1_aw20_samsmu_student', 'p1_aw20_sevsu_student',   'p1_aw20_sgau_student',   'p1_aw20_sfedu_student',  'p1_aw20_spbgau_student', 
				  'p1_aw20_ssau_student',   'p1_aw20_stsau_student',   'p1_aw20_sursau_student', 'p1_aw20_timacad_student','p1_aw20_tsaa_student',   
				  'p1_aw20_tstu_student',   'p1_aw20_ugrasu_student', 'p1_aw20_ulsau_student',   'p1_aw20_volgsau_student','p1_aw20_vsau_student',   
				  'p1_aw20_vstu_student'
				 )
				 AND ui.untiID IS NOT NULL)
SELECT ui.untiID, e.id AS event_ID, ufa.value, fq.title AS question, fq.id
FROM	const,
		labs.user_feedback_answer AS ufa
		LEFT JOIN labs.feedback_question  as fq ON fq.id=ufa.feedbackQuestionID 
		LEFT JOIN labs.event e ON e.id=ufa.eventID	
		left JOIN labs.user_info as ui ON (ufa.userID=ui.userID AND ui.untiID IS NOT NULL) 
		left JOIN uid ON uid.untiID=ui.untiID
		left join labs.run r on r.id = e.runID
		left JOIN labs.activity a on a.id=r.activityID
		left join labs.context_activity ca on ca.activityID = a.id
WHERE ca.contextID=285  AND  ufa.createDT>const.milestone_start-1  AND ufa.createDT<=const.milestone_end+1	AND
		fq.type='rating' AND uid.untiID IS NOT NULL; 
