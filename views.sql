USE JUDGE_DB;

-- ----------------------------------------------------------
-- -------------- vw_submission_activity --------------------
-- Shows how many submissions has every user made a certain
-- date. If no submissions were made a certain date by a given
-- user, then that certain date does not appear in the result
-- set.
-- ----------------------------------------------------------
DROP VIEW IF EXISTS vw_submission_activity;
CREATE VIEW vw_submission_activity 
	AS
    (SELECT contestant_handle, DATE(submission.date) AS date, COUNT(*) AS number_of_submissions
	FROM submission
    GROUP BY contestant_handle, DATE(submission.date)
	ORDER BY DATE(submission.date) ASC);
    

-- ----------------------------------------------------------
-- -------------- vw_problem_times_solved --------------------
-- Shows how many times a problem with a certain id has been
-- solved.
-- ----------------------------------------------------------
DROP VIEW IF EXISTS vw_problem_times_solved;
CREATE VIEW vw_problem_times_solved
	AS
    (SELECT problem.id, COUNT(DISTINCT contestant_handle) AS times_solved
	FROM problem
	INNER JOIN submission ON (problem.id = submission.problem_id)
    WHERE submission.status = 'AC'
    GROUP BY problem.id);