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
