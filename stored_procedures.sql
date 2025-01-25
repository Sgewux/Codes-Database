USE JUDGE_DB ;

-- -----------------------------------------------------
-- Authentication
-- -----------------------------------------------------

/*

*/
DROP PROCEDURE IF EXISTS register;
DELIMITER $$
CREATE PROCEDURE register(
	IN p_handle VARCHAR(20),
	IN p_first_name VARCHAR(45),
	IN p_last_name VARCHAR(45),
	IN p_password VARCHAR(100)
)
	BEGIN
		DECLARE handle_exists INT;

		SELECT COUNT(*) INTO handle_exists
		FROM JUDGE_DB.USER
		WHERE handle = p_handle;

		IF handle_exists > 0 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Handle already used';
		ELSE
			INSERT INTO JUDGE_DB.USER (handle, first_name, last_name, password)
			VALUES (p_handle, p_first_name, p_last_name, p_password);
		END IF;
	END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS get_user_roles;
DELIMITER $$
CREATE PROCEDURE get_user_roles(IN user_handle VARCHAR(255))
BEGIN
    DECLARE roles_list TEXT DEFAULT '';

    IF EXISTS (SELECT 1 FROM JUDGE_DB.ADMIN WHERE handle = user_handle) THEN
        SET roles_list = CONCAT(roles_list, 'ADMIN ');
    END IF;

    IF EXISTS (SELECT 1 FROM JUDGE_DB.CONTESTANT WHERE handle = user_handle) THEN
        SET roles_list = CONCAT(roles_list, 'CONTESTANT ');
    END IF;

    IF EXISTS (SELECT 1 FROM JUDGE_DB.PROBLEMSETTER WHERE handle = user_handle) THEN
        SET roles_list = CONCAT(roles_list, 'PROBLEMSETTER ');
    END IF;

    IF CHAR_LENGTH(roles_list) > 0 THEN
        SET roles_list = LEFT(roles_list, CHAR_LENGTH(roles_list) - 1);
    ELSE
        SET roles_list = 'NO ROLES FOUND';
    END IF;
    
    SELECT roles_list AS roles;
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Users
-- -----------------------------------------------------

/*

*/
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
-- Submissions
-- -----------------------------------------------------

/*

*/
DROP PROCEDURE IF EXISTS get_user_AC_sumbissions;
DELIMITER $$
CREATE PROCEDURE get_user_AC_sumbissions(IN problemId INT)
BEGIN
    SELECT *
    FROM vw_user_ac_submissions
    WHERE problem_id = problemId;
END$$
DELIMITER ;


/*

*/
DROP PROCEDURE IF EXISTS get_user_submissions;
DELIMITER $$
CREATE PROCEDURE get_user_submissions(IN problemId INT)
BEGIN
    SELECT *
    FROM vw_user_submissions
    WHERE problem_id = problemId;
END$$
DELIMITER ;


/*

*/
DROP PROCEDURE IF EXISTS get_user_submissions;
DELIMITER $$
CREATE PROCEDURE get_user_submissions(IN user_handle VARCHAR(255) )
BEGIN
    SELECT 
        s.problem_id, 
        s.submission_id, 
        s.code, 
        s.execution_time_seconds, 
        s.date, 
        s.status,
        p.times_solved
    FROM vw_user_submissions s
    LEFT JOIN vw_problem_times_solved p ON s.problem_id = p.id
    WHERE s.contestant_handle = user_handle;
END $$
DELIMITER ;

/*

*/
DROP PROCEDURE IF EXISTS get_submissions_count_by_handle;
DELIMITER $$
CREATE PROCEDURE get_submissions_count_by_handle(IN contestant_handle VARCHAR(255))
BEGIN
    SELECT COUNT(*) AS TotalSubmissions
    FROM JUDGE_DB.SUBMISSION
    WHERE contestant_handle = contestant_handle;
END $$
DELIMITER ;


/*

*/
DROP PROCEDURE IF EXISTS get_submission_activity;
DELIMITER $$
CREATE PROCEDURE get_submission_activity(handle VARCHAR(20), from_d DATE, to_d DATE)
	BEGIN
		SELECT * FROM vw_submission_activity 
        WHERE contestant_handle = handle AND vw_submission_activity.date >= from_d AND vw_submission_activity.date <= to_d 
        ;
    END $$
DELIMITER ;


-- -----------------------------------------------------
-- Problems
-- -----------------------------------------------------

/*

*/
DROP PROCEDURE IF EXISTS get_problem_details_for_user;
DELIMITER $$
CREATE PROCEDURE get_problem_details_for_user(handle VARCHAR(20), filt ENUM('all', 'accepted', 'tried'), lm INT, ofS INT)
	BEGIN

    IF filt = 'all' THEN
		SELECT COUNT(*) AS records FROM vw_problem_details;
        
		SELECT id, name, author, editorial, times_solved, get_problem_status(id, handle) AS status
        FROM vw_problem_details LIMIT lm OFFSET ofs;
        
	ELSEIF filt = 'accepted' THEN
		SELECT COUNT(*) AS records FROM (SELECT id, name, author, editorial, times_solved, get_problem_status(id, handle) AS status
        FROM vw_problem_details) as t1  WHERE  status='AC';
		
  		SELECT * FROM (SELECT id, name, author, editorial, times_solved, get_problem_status(id, handle) AS status
        FROM vw_problem_details) as t1  WHERE  status='AC'
        LIMIT lm OFFSET ofs;  
        
	ELSEIF filt = 'tried' THEN
		SELECT COUNT(*) AS records FROM (SELECT id, name, author, editorial, times_solved, get_problem_status(id, handle) AS status
        FROM vw_problem_details) as t1  WHERE status!='NT' AND status!='AC';
        
  		SELECT * FROM (SELECT id, name, author, editorial, times_solved, get_problem_status(id, handle) AS status
        FROM vw_problem_details) as t1  WHERE status!='NT' AND status!='AC'
        LIMIT lm OFFSET ofs;  
	END IF;
    END $$
DELIMITER ;


/*

*/
DROP PROCEDURE IF EXISTS get_problem_details_by_name;
DELIMITER $$
CREATE PROCEDURE get_problem_details_by_name(p_name VARCHAR(45), handle VARCHAR(20), lm INT, ofs INT)
	BEGIN
		SELECT COUNT(*) AS records FROM (SELECT id, name, author, editorial, times_solved, get_problem_status(id, handle) AS status
        FROM vw_problem_details) as t1  WHERE name LIKE CONCAT(p_name, '%');
		
  		SELECT * FROM (SELECT id, name, author, editorial, times_solved, get_problem_status(id, handle) AS status
        FROM vw_problem_details) as t1  WHERE name LIKE CONCAT(p_name, '%')
        LIMIT lm OFFSET ofs;
    END $$
DELIMITER ;

/*

*/
DROP PROCEDURE IF EXISTS get_problem_by_id;
DELIMITER $$
CREATE PROCEDURE get_problem_by_id(problem_id INT)
	BEGIN
		SELECT id, name, problemsetter_handle AS 'author', time_limit_seconds AS 'timeLimitSeconds', statement, editorial
		FROM problem WHERE id = problem_id;
    END $$
DELIMITER ;

-- -----------------------------------------------------
-- USER PAGE
-- -----------------------------------------------------

/*

*/
DROP PROCEDURE IF EXISTS get_AC_count_by_handle;
DELIMITER $$
CREATE PROCEDURE get_AC_count_by_handle(IN contestant_handle VARCHAR(255))
BEGIN
    SELECT COUNT(DISTINCT Problem_id) AS TotalAC
    FROM JUDGE_DB.SUBMISSION
    WHERE contestant_handle = contestant_handle
      AND status = 'AC';
END $$
DELIMITER ;


/*

*/
DROP PROCEDURE IF EXISTS get_AC_count_by_handle_lastmonth;
DELIMITER $$
CREATE PROCEDURE get_AC_count_by_handle_lastmonth(IN contestant_handle VARCHAR(255))
BEGIN
    SELECT COUNT(DISTINCT Problem_id) AS TotalRecentAC
    FROM JUDGE_DB.SUBMISSION
    WHERE contestant_handle = contestant_handle
      AND status = 'AC'
      AND `date` >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
END $$
DELIMITER ;
