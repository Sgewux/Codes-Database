USE JUDGE_DB ;

-- -----------------------------------------------------
-- Authentication
-- -----------------------------------------------------

-- 
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


-- -----------------------------------------------------
-- Users
-- -----------------------------------------------------

-- 
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

-- -----------------------------------------------------
-- get AC user submissions
-- -----------------------------------------------------

--
DROP PROCEDURE IF EXISTS get_User_AC_sumbissions;
DELIMITER $$
CREATE PROCEDURE get_User_AC_sumbissions(IN problemId INT)
BEGIN
    SELECT *
    FROM vw_user_ac_submissions
    WHERE problem_id = problemId;
END$$
DELIMITER ;



-- -----------------------------------------------------
-- get All User submissions
-- -----------------------------------------------------

--
DROP PROCEDURE IF EXISTS get_User_submissions;
DELIMITER $$
CREATE PROCEDURE get_User_submissions(IN problemId INT)
BEGIN
    SELECT *
    FROM vw_user_submissions
    WHERE problem_id = problemId;
END$$
DELIMITER ;


-- -----------------------------------------------------
-- get User roles
-- -----------------------------------------------------

--
DROP PROCEDURE IF EXISTS GetUserRoles;

DELIMITER $$
CREATE PROCEDURE GetUserRoles(IN user_handle VARCHAR(255))
BEGIN
    DECLARE roles_list TEXT DEFAULT '';

    IF EXISTS (SELECT 1 FROM JUDGE_DB.ADMIN WHERE handle = user_handle) THEN
        SET roles_list = CONCAT(roles_list, 'ADMIN, ');
    END IF;

    IF EXISTS (SELECT 1 FROM JUDGE_DB.CONTESTANT WHERE handle = user_handle) THEN
        SET roles_list = CONCAT(roles_list, 'CONTESTANT, ');
    END IF;

    IF EXISTS (SELECT 1 FROM JUDGE_DB.PROBLEMSETTER WHERE handle = user_handle) THEN
        SET roles_list = CONCAT(roles_list, 'PROBLEMSETTER, ');
    END IF;

    IF CHAR_LENGTH(roles_list) > 0 THEN
        SET roles_list = LEFT(roles_list, CHAR_LENGTH(roles_list) - 2);
    ELSE
        SET roles_list = 'NO ROLES FOUND';
    END IF;

    -- Devolver los roles encontrados
    SELECT roles_list AS roles;
END;$$
DELIMITER ;

CALL GetUserRoles('lellsom17');




DROP PROCEDURE IF EXISTS query_submission_activity;
DELIMITER $$
CREATE PROCEDURE query_submission_activity(handle VARCHAR(20), from_d DATE, to_d DATE)
	BEGIN
		SELECT * FROM vw_submission_activity 
        WHERE contestant_handle = handle AND vw_submission_activity.date >= from_d AND vw_submission_activity.date <= to_d 
        ;
    END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS query_problem_details_for_user;
DELIMITER $$
CREATE PROCEDURE query_problem_details_for_user(handle VARCHAR(20), filt ENUM('all', 'accepted', 'tried'), lm INT, ofS INT)
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

DROP PROCEDURE IF EXISTS query_problem_details_by_name;
DELIMITER $$
CREATE PROCEDURE query_problem_details_by_name(p_name VARCHAR(45), handle VARCHAR(20), lm INT, ofs INT)
	BEGIN
		SELECT COUNT(*) AS records FROM (SELECT id, name, author, editorial, times_solved, get_problem_status(id, handle) AS status
        FROM vw_problem_details) as t1  WHERE name LIKE CONCAT(p_name, '%');
		
  		SELECT * FROM (SELECT id, name, author, editorial, times_solved, get_problem_status(id, handle) AS status
        FROM vw_problem_details) as t1  WHERE name LIKE CONCAT(p_name, '%')
        LIMIT lm OFFSET ofs;
    END $$
DELIMITER ;