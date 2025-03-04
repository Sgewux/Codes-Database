USE JUDGE_DB;

-- -----------------------------------------------------
-- Problems
-- -----------------------------------------------------

/*
    Retrieves problem details for a specific user, filtered by problem status.

    Filters:
    - 'all'       → Retrieves all problems.
    - 'accepted'  → Retrieves problems the user has solved.
    - 'tried'     → Retrieves problems the user has attempted but not solved.

    Supports pagination using `lm` (limit) and `ofs` (offset).
*/
DROP PROCEDURE IF EXISTS get_problem_details_for_user;
DELIMITER $$
CREATE PROCEDURE get_problem_details_for_user(
    handle VARCHAR(20), 
    filt ENUM('all', 'accepted', 'tried'), 
    lm INT, 
    ofS INT
)
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
    Retrieves problem details based on the problem's name.

    - Uses a prefix search (matches names starting with `p_name`).
    - Includes the user's problem status.
    - Supports pagination with `lm` (limit) and `ofs` (offset).
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
    Retrieves detailed information about a problem using its unique ID.
*/
DROP PROCEDURE IF EXISTS get_problem_by_id;
DELIMITER $$
CREATE PROCEDURE get_problem_by_id(problem_id INT)
BEGIN
	SELECT id, name, problemsetter_handle AS 'author', time_limit_seconds AS 'timeLimitSeconds', statement, editorial
	FROM problem 
    WHERE id = problem_id;
END $$
DELIMITER ;


/*
    Creates a new problem and inserts an initial test case.

    - Stores problem details such as statement, editorial, and constraints.
    - Assigns the problem to the specified problem setter.
    - Inserts an initial test case into the `TEST` table.
    - Returns the newly created problem ID.
*/
DROP PROCEDURE IF EXISTS create_problem;
DELIMITER $$
CREATE PROCEDURE create_problem(
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


/*
    Retrieves all problems created by a specific problem setter.
*/
DROP PROCEDURE IF EXISTS read_problem_by_problemsetter_handle;
DELIMITER $$
CREATE PROCEDURE read_problem_by_problemsetter_handle(IN user_handle VARCHAR(20))
BEGIN
    SELECT * 
    FROM vw_problem_details_CRUD 
    WHERE problemsetter_handle = user_handle;
END $$
DELIMITER ;


/*
    Updates an existing problem's statement or editorial.

    - If `p_statement` or `p_editorial` is empty, the existing value is retained.
*/
DROP PROCEDURE IF EXISTS update_problem;
DELIMITER $$
CREATE PROCEDURE update_problem(
    IN p_problem_id INT,
    IN p_statement TEXT,
    IN p_editorial TEXT
)
BEGIN
    UPDATE JUDGE_DB.PROBLEM
    SET 
        statement = IFNULL(NULLIF(p_statement, ''), statement),
        editorial = IFNULL(NULLIF(p_editorial, ''), editorial)
    WHERE id = p_problem_id;
END $$
DELIMITER ;


/*
    Deletes a problem and its associated test cases.
*/
DROP PROCEDURE IF EXISTS delete_problem;
DELIMITER $$
CREATE PROCEDURE delete_problem(IN p_problem_id INT)
BEGIN
	DELETE FROM JUDGE_DB.TEST WHERE Problem_id = p_problem_id;
    DELETE FROM JUDGE_DB.PROBLEM WHERE id = p_problem_id;
END $$
DELIMITER ;


/*
    Retrieves all test cases associated with a specific problem.
*/
DROP PROCEDURE IF EXISTS get_problem_tests;
DELIMITER $$
CREATE PROCEDURE get_problem_tests(IN p_problem_id INT)
BEGIN
    SELECT number, input, output
    FROM JUDGE_DB.TEST
    WHERE Problem_id = p_problem_id;
END $$
DELIMITER ;


/*
    Retrieves the time limit (in seconds) for a specific problem.
*/
DROP PROCEDURE IF EXISTS get_problem_time_limit;
DELIMITER $$
CREATE PROCEDURE get_problem_time_limit(IN problem_id INT)
BEGIN
    SELECT time_limit_seconds 
    FROM JUDGE_DB.PROBLEM 
    WHERE id = problem_id;
END $$
DELIMITER ;
