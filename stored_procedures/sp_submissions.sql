USE JUDGE_DB;

-- -----------------------------------------------------
-- Submissions
-- -----------------------------------------------------

/*

*/
DROP PROCEDURE IF EXISTS get_user_submissions;
DELIMITER $$
CREATE PROCEDURE get_user_submissions(
    IN user_handle VARCHAR(255),
    IN filter ENUM('all', 'accepted', 'tried'),
    IN limit_value INT,
    IN offset_value INT
)
BEGIN

    SELECT s.id, s.problem_name, s.date, s.status
    FROM vw_user_submissions s
    WHERE s.contestant_handle = user_handle
    AND (
        filter = 'all' 
        OR (filter = 'accepted' AND s.status = 'AC') 
        OR (filter = 'tried' AND s.status != 'AC')
    )
    LIMIT limit_value OFFSET offset_value;
END $$
DELIMITER ;


/*

*/
DROP PROCEDURE IF EXISTS count_user_submissions;
DELIMITER $$
CREATE PROCEDURE count_user_submissions(
    IN user_handle VARCHAR(255),
    IN filter ENUM('all', 'accepted', 'tried')
)
BEGIN
    SELECT COUNT(*) AS submission_count
    FROM vw_user_submissions s
    WHERE s.contestant_handle = user_handle
    AND (
        filter = 'all' 
        OR (filter = 'accepted' AND s.status = 'AC') 
        OR (filter = 'tried' AND s.status != 'AC')
    );
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


/* 

*/
DROP PROCEDURE IF EXISTS get_submission_by_id;
DELIMITER $$
CREATE PROCEDURE get_submission_by_id(id INT)
	BEGIN
		SELECT 
			submission.id, problem.id AS problemId, contestant_handle AS contestant, name AS problemName, status , 
			execution_time_seconds AS executionTime, date, code
        
		FROM submission
		INNER JOIN problem ON submission.problem_id = problem.id
        WHERE submission.id = id;
    END $$
DELIMITER ;


/*

*/
DROP PROCEDURE IF EXISTS create_submission;
DELIMITER $$
CREATE PROCEDURE create_submission(
    IN p_contestant_handle VARCHAR(20),
    IN p_problem_id INT,
    IN p_code TEXT
)
BEGIN
    INSERT INTO JUDGE_DB.SUBMISSION (
        status, execution_time_seconds, date, code, problem_id, contestant_handle
    ) VALUES (
        'QU', 0.000, NOW(), p_code, p_problem_id, p_contestant_handle
    );
    SELECT LAST_INSERT_ID() AS submission_id;
END $$
DELIMITER ;


/*

*/
DROP PROCEDURE IF EXISTS update_submission_verdict;
DELIMITER $$
CREATE PROCEDURE update_submission_verdict(
    IN p_submission_id INT,
    IN p_new_status ENUM('QU', 'AC', 'WA', 'TL', 'RT', 'CE'),
    IN p_execution_time_seconds FLOAT
)
BEGIN
    UPDATE JUDGE_DB.SUBMISSION
    SET status = p_new_status,
        execution_time_seconds = p_execution_time_seconds
    WHERE id = p_submission_id;
END $$
DELIMITER ;
