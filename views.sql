USE JUDGE_DB;

-- -----------------------------------------------------
-- Submissions
-- -----------------------------------------------------

/*
	Shows how many submissions has every user made a certain
	date. If no submissions were made a certain date by a given
	user, then that certain date does not appear in the result
	set.
*/
DROP VIEW IF EXISTS vw_submission_activity;
CREATE VIEW vw_submission_activity 
	AS
    (SELECT contestant_handle, DATE(submission.date) AS date, COUNT(*) AS number_of_submissions
	FROM submission
    GROUP BY contestant_handle, DATE(submission.date)
	ORDER BY DATE(submission.date) ASC);
    
    
/*
	Shows all information necesary for submissions table in user page
*/
DROP VIEW IF EXISTS vw_user_submissions;
CREATE VIEW vw_user_submissions AS
SELECT s.id, s.problem_id, p.name AS problem_name, s.date, s.status, s.contestant_handle
FROM JUDGE_DB.SUBMISSION s
JOIN JUDGE_DB.PROBLEM p ON s.problem_id = p.id; 


    
-- -----------------------------------------------------
-- Problems
-- -----------------------------------------------------

/*
	Shows how many times a problem with a certain id has been
	solved.
*/
DROP VIEW IF EXISTS vw_problem_times_solved;
CREATE VIEW vw_problem_times_solved
	AS
    (SELECT problem.id, COUNT(DISTINCT contestant_handle) AS times_solved
	FROM problem
	INNER JOIN submission ON (problem.id = submission.problem_id)
    WHERE submission.status = 'AC'
    GROUP BY problem.id);
    

/*
	Shows all the information necesary for the problems page 
	(All problems).
*/
DROP VIEW IF EXISTS vw_problem_details;
CREATE VIEW vw_problem_details AS
SELECT p.id, p.name, p.problemsetter_handle AS author, p.editorial, IFNULL(times_solved, 0) AS times_solved
	FROM JUDGE_DB.PROBLEM p
    LEFT JOIN vw_problem_times_solved ON p.id = vw_problem_times_solved.id;
