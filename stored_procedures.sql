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
