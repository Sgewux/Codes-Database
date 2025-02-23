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