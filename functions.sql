-- -----------------------------------------------------------------
-- ---------------- get_problem_status -----------------------------
-- Returns the problem status for a given user in a given problem
-- returns AC if the user has solved the problem at least once
-- returns NT if the user has not made any submissions to this problem
-- otherwise, returns the status of the last submission.
-- -----------------------------------------------------------------
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