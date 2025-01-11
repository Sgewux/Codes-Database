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
DROP PROCEDURE IF EXISTS find_user_by_id;
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

CALL get_User_AC_sumbissions(45);



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


DROP PROCEDURE IF EXISTS query_submission_activity;
DELIMITER $$
CREATE PROCEDURE query_submission_activity(handle VARCHAR(20))
	BEGIN
		SELECT * FROM vw_submission_activity WHERE contestant_handle = handle;
    END $$
DELIMITER ;
