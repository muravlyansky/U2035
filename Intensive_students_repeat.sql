
WITH uid_s AS (SELECT  distinct ui.untiID, ui.leaderID, ui.userID  AS ple_userID, 
							t.title AS VUZ_tag 
				 FROM ple.user_info  as ui 
				 LEFT JOIN ple.user_tag AS ut ON ut.userID=ui.userID
				 LEFT JOIN ple.tag AS t ON t.id=ut.tagID
				 WHERE t.title in ('p1_ncfu_student_ss20', 'p1_sevsu_student_ss20', 'p1_vyatsu_student_ss20',
						'p1_rsue_student_ss20', 'p1_chuvsu_student_ss20', 'p1_sfu_student_ss20',
						'p1_vstu_student_ss20', 'p1_tolsu_student_ss20', 'p1_mits_student_ss20',
						'p1_ugrasu_student_ss20')
	),
	uid_aw AS (SELECT  distinct ui.untiID, ui.leaderID, ui.userID  AS ple_userID, 
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
	)	  
SELECT count(uid_s.untiID), uid_s.VUZ_tag, uid_aw.VUZ_tag
FROM uid_s, uid_aw
WHERE uid_s.untiID=uid_aw.untiID
GROUP BY uid_s.VUZ_tag;
