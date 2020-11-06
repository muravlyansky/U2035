WITH const AS 
	  (SELECT   1 as period_id, STR_TO_DATE("15 09 2020","%d %m %Y") AS milestone_start, STR_TO_DATE("16 10 2020","%d %m %Y") AS milestone_end, 
				STR_TO_DATE("15 09 2020","%d %m %Y") AS intensive_start
	   UNION
	   SELECT   2 as period_id, STR_TO_DATE("17 10 2020","%d %m %Y") AS milestone_start, STR_TO_DATE("30 10 2020","%d %m %Y") AS milestone_end,
				STR_TO_DATE("15 09 2020","%d %m %Y") AS intensive_start
	  ),
	 uid AS 
	 (SELECT  distinct ui.untiID, ui.leaderID, ui.userID  AS ple_userID, 
							t.title AS VUZ_tag 
				 FROM ple.user_info  as ui 
				 LEFT JOIN ple.user_tag AS ut ON ut.userID=ui.userID
				 LEFT JOIN ple.tag AS t ON t.id=ut.tagID
				 WHERE ui.untiID IS NOT NULL  AND t.title IN 
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
		) 
SELECT ui.uID AS untiID, uid.leaderID, uid.VUZ_tag, cicp.course_id, cicp.is_completed AS finished, cicp.overall_progress AS progress, 
				   cicp.enrolled_at,cicp.last_activity_at, const.period_id AS period_id
			FROM const,  uid
			LEFT JOIN cat.social_auth_usersocialauth AS ui ON (uid.untiID=ui.uid AND ui.uid IS NOT NULL)
			LEFT JOIN cat.coursera_integration_courserauser AS cic ON cic.user_id=ui.user_ID 
			LEFT JOIN cat.coursera_integration_courserausercourseprogress AS cicp ON cicp.coursera_user_id = cic.id
			WHERE (JSON_UNQUOTE((json_extract(json_extract(cicp.history, '$[0]'), '$.timestamp')))<=const.milestone_end+1) AND
				  (JSON_UNQUOTE((json_extract(json_extract(cicp.history, '$[0]'), '$.timestamp')))>=const.intensive_start) AND 
				  uid.untiID is not NULL; 