USE JUDGE_DB;
-- -----------------------------------------------------
-- Users
-- -----------------------------------------------------

DROP PROCEDURE IF EXISTS find_user_by_handle;
DELIMITER $$
CREATE PROCEDURE find_user_by_handle(IN p_handle VARCHAR(20))
	BEGIN
		DECLARE user_found INT;

		SELECT COUNT(*) INTO user_found
		FROM JUDGE_DB.USER
		WHERE handle = p_handle;

		IF user_found > 0 THEN
			SELECT *
			FROM JUDGE_DB.USER
			WHERE handle = p_handle;
		ELSE
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found';
		END IF;
	END $$
DELIMITER ;




DROP PROCEDURE IF EXISTS get_user_summary_for_user;
DELIMITER $$
CREATE PROCEDURE  get_user_summary_for_user(p_handle VARCHAR(20), lm INT, ofs INT)
	BEGIN 
    
	SELECT COUNT(*)
		FROM 
		contestant
		LEFT JOIN (SELECT contestant_handle, COUNT(*) AS ACSubmissions FROM vw_user_ac_submissions GROUP BY contestant_handle) AS t1
		ON t1.contestant_handle = handle
		LEFT JOIN (SELECT contestant_handle, COUNT(*) AS submissions FROM vw_user_submissions GROUP BY contestant_handle) AS t2
		ON t2.contestant_handle = handle
        WHERE contestant.handle != p_handle;
    
    SELECT handle, IFNULL(submissions,0) AS submissions , IFNULL(ACSubmissions,0) AS ACSubmissions,
			get_days_from_last_submission(handle) AS lastSubmissionDaysAgo, is_friend(handle, p_handle) AS isFriend
		FROM 
		contestant
		LEFT JOIN (SELECT contestant_handle, COUNT(*) AS ACSubmissions FROM vw_user_ac_submissions GROUP BY contestant_handle) AS t1
		ON t1.contestant_handle = handle
		LEFT JOIN (SELECT contestant_handle, COUNT(*) AS submissions FROM vw_user_submissions GROUP BY contestant_handle) AS t2
		ON t2.contestant_handle = handle
        WHERE contestant.handle != p_handle
        LIMIT lm OFFSET ofs;
    END $$
DELIMITER ;


-- -----------------------------------------------------
-- USER PAGE
-- -----------------------------------------------------

/*

*/
DROP PROCEDURE IF EXISTS get_AC_statistics;

DELIMITER $$
CREATE PROCEDURE get_AC_statistics(IN in_contestant_handle VARCHAR(255))
BEGIN
    SELECT 
        COUNT(DISTINCT CASE WHEN status = 'AC' THEN Problem_id END) AS TotalAC,
        COUNT(DISTINCT CASE WHEN status = 'AC' AND `date` >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN Problem_id END) AS TotalRecentAC,
        COUNT(*) AS TotalSubmissions
    FROM JUDGE_DB.SUBMISSION
    WHERE contestant_handle = in_contestant_handle;
END $$
DELIMITER ;
