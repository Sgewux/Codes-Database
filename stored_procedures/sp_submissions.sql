USE JUDGE_DB;
-- -----------------------------------------------------
-- Submissions
-- -----------------------------------------------------

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
DROP PROCEDURE IF EXISTS get_submission_activity;

DELIMITER $$
CREATE PROCEDURE get_submission_activity(handle VARCHAR(20), from_d DATE, to_d DATE)
	BEGIN
		SELECT * FROM vw_submission_activity 
        WHERE contestant_handle = handle AND vw_submission_activity.date >= from_d AND vw_submission_activity.date <= to_d 
        ;
    END $$
DELIMITER ;
