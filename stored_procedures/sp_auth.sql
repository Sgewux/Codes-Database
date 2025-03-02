USE JUDGE_DB;

-- -----------------------------------------------------
-- Authentication
-- -----------------------------------------------------

/*
	Registers a new user in the system by inserting their details into the `USER` table 
	and automatically assigning them the "contestant" role.
*/
DROP PROCEDURE IF EXISTS register_contestant;
DELIMITER $$
CREATE PROCEDURE register_contestant(
	IN p_handle VARCHAR(20),
	IN p_first_name VARCHAR(45),
	IN p_last_name VARCHAR(45),
	IN p_password VARCHAR(100)
)
BEGIN
	INSERT INTO JUDGE_DB.USER (handle, first_name, last_name, password)
	VALUES (p_handle, p_first_name, p_last_name, p_password);
        
	INSERT INTO JUDGE_DB.CONTESTANT (handle) VALUES (p_handle);
END $$
DELIMITER ;


/*
	Retrieves the roles assigned to a given user and returns them as a table.
*/
DROP PROCEDURE IF EXISTS get_user_roles;
DELIMITER $$
CREATE PROCEDURE get_user_roles(IN user_handle VARCHAR(255))
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_roles (role_name VARCHAR(50));

    IF EXISTS (SELECT 1 FROM JUDGE_DB.ADMIN WHERE handle = user_handle) THEN
        INSERT INTO temp_roles (role_name) VALUES ('admin');
    END IF;

    IF EXISTS (SELECT 1 FROM JUDGE_DB.CONTESTANT WHERE handle = user_handle) THEN
        INSERT INTO temp_roles (role_name) VALUES ('contestant');
    END IF;

    IF EXISTS (SELECT 1 FROM JUDGE_DB.PROBLEMSETTER WHERE handle = user_handle) THEN
        INSERT INTO temp_roles (role_name) VALUES ('problem_setter');
    END IF;

    SELECT * FROM temp_roles;

    DROP TEMPORARY TABLE temp_roles;
END $$
DELIMITER ;
