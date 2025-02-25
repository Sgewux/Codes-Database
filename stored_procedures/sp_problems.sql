USE JUDGE_DB;

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


/*
	CURD
*/

DROP PROCEDURE IF EXISTS sp_create_problem;

DELIMITER $$

CREATE PROCEDURE sp_create_problem(
    IN p_name VARCHAR(225),
    IN p_statement TEXT,
    IN p_editorial TEXT,
    IN p_time_limit_seconds INT,
    IN p_memory_limit_mb INT,
    IN p_problemsetter_handle VARCHAR(225),
    IN p_test_input TEXT,
    IN p_test_output TEXT
)
BEGIN
    DECLARE last_problem_id INT;

    INSERT INTO JUDGE_DB.PROBLEM (name, statement, editorial, time_limit_seconds, memory_limit_mb, problemsetter_handle)
    VALUES (p_name, p_statement, p_editorial, p_time_limit_seconds, p_memory_limit_mb, p_problemsetter_handle);

    SET last_problem_id = LAST_INSERT_ID();

    INSERT INTO JUDGE_DB.TEST (number, Problem_id, input, output)
    VALUES (1, last_problem_id, p_test_input, p_test_output);

    SELECT last_problem_id AS problem_id;
END $$

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_read_problem_by_handle;
DELIMITER $$

CREATE PROCEDURE sp_read_problem_by_handle( IN user_handle VARCHAR(20))
BEGIN
    SELECT * FROM vw_problems WHERE problemsetter_handle = user_handle;
END $$

DELIMITER ;