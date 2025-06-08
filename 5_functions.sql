USE JUDGE_DB;

-- -----------------------------------------------------
-- Problems
-- -----------------------------------------------------

/*
	Returns the problem status for a given user in a given problem
	Returns AC if the user has solved the problem at least once
	Returns NT if the user has not made any submissions to this problem
	Otherwise, returns the status of the last submission.
*/
DROP FUNCTION IF EXISTS get_problem_status;
DELIMITER $$
CREATE FUNCTION get_problem_status(problem_id INT, contestant_handle VARCHAR(20)) RETURNS ENUM('AC', 'WA', 'TL', 'RT', 'CE', 'NT') DETERMINISTIC
BEGIN
	DECLARE AC_count INT;
    DECLARE submit_count INT;
    DECLARE last_veredict ENUM('AC', 'WA', 'TL', 'RT', 'CE');
    SELECT SUM(status='AC') FROM submission 
		WHERE submission.problem_id = problem_id  AND submission.contestant_handle = contestant_handle INTO AC_count;
	SELECT COUNT(*) FROM submission 
		WHERE submission.problem_id = problem_id  AND submission.contestant_handle = contestant_handle AND submission.status != 'QU' 
        INTO submit_count;
	SELECT submission.status FROM submission 
		WHERE submission.problem_id = problem_id  AND submission.contestant_handle = contestant_handle
        ORDER BY submission.date DESC
        LIMIT 1
        INTO last_veredict;
            
	IF submit_count = 0 THEN RETURN 'NT';
    ELSEIF AC_count > 0 THEN RETURN 'AC';
    ELSE RETURN last_veredict;
    END IF;        
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Users
-- -----------------------------------------------------

/*
	Given the user handle, gets how many days have passed from his last submission.
    Returns NULL if the user has not submitted any code.
*/
DROP FUNCTION IF EXISTS get_days_from_last_submission;
DELIMITER $$
CREATE FUNCTION get_days_from_last_submission(handle VARCHAR(20)) RETURNS INT DETERMINISTIC
BEGIN 
    DECLARE last_submit_date DATE;
    DECLARE submit_count INT;
    
    SELECT COUNT(*) FROM vw_user_submissions WHERE vw_user_submissions.contestant_handle = handle INTO submit_count;
    
    IF submit_count = 0 THEN RETURN NULL;
    ELSE 
		SELECT date FROM vw_user_submissions WHERE vw_user_submissions.contestant_handle = handle ORDER BY date DESC LIMIT 1 INTO last_submit_date;
        RETURN TO_DAYS(NOW()) - TO_DAYS(last_submit_date);
    END IF;    
END $$
DELIMITER ;

/*
	Given two handles returns true if contestant with handle1 is in the friends list of contestant with handle2
*/
DROP FUNCTION IF EXISTS is_friend;
DELIMITER $$
CREATE FUNCTION is_friend(handle1 VARCHAR(20), handle2 VARCHAR(20)) RETURNS BOOLEAN DETERMINISTIC
BEGIN
	DECLARE cnt INT;
	SELECT COUNT(*) FROM friendship WHERE contestant_handle = handle2 AND friend_handle = handle1 INTO cnt;
        
    IF cnt = 0 THEN RETURN FALSE;
    ELSE RETURN TRUE;
    END IF;
END $$
DELIMITER ;
