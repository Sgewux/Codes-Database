USE JUDGE_DB;

-- -----------------------------------------------------
-- Users
-- -----------------------------------------------------

/*
    Searches for a user in the `USER` table using their unique handle.
*/
DROP PROCEDURE IF EXISTS find_user_by_handle;
DELIMITER $$
CREATE PROCEDURE find_user_by_handle(IN p_handle VARCHAR(20))
BEGIN
    SELECT * 
    FROM JUDGE_DB.USER 
    WHERE handle = p_handle;
END $$
DELIMITER ;


/*
    Retrieves a summary of users, either all users or only friends of a given user.

    Filters:
    - 'all'     → Retrieves all users except the given user.
    - 'friends' → Retrieves only friends of the given user.

    Supports pagination using `lm` (limit) and `ofs` (offset).
*/
DROP PROCEDURE IF EXISTS get_user_summary_for_user;
DELIMITER $$
CREATE PROCEDURE get_user_summary_for_user(
    IN p_handle VARCHAR(20), 
    IN filt ENUM('all', 'friends'), 
    IN lm INT, 
    IN ofs INT
)
BEGIN 
    IF filt = 'all' THEN
        -- Count total records
        SELECT COUNT(*) AS records
        FROM contestant
        LEFT JOIN (SELECT contestant_handle, COUNT(*) AS ACSubmissions FROM vw_user_ac_submissions GROUP BY contestant_handle) AS t1
            ON t1.contestant_handle = handle
        LEFT JOIN (SELECT contestant_handle, COUNT(*) AS submissions FROM vw_user_submissions GROUP BY contestant_handle) AS t2
            ON t2.contestant_handle = handle
        WHERE contestant.handle != p_handle;

        -- Retrieve user summary
        SELECT handle, 
            IFNULL(submissions, 0) AS submissions, 
            IFNULL(ACSubmissions, 0) AS ACSubmissions,
            get_days_from_last_submission(handle) AS lastSubmissionDaysAgo, 
            is_friend(handle, p_handle) AS isFriend
        FROM contestant
        LEFT JOIN (SELECT contestant_handle, COUNT(*) AS ACSubmissions FROM vw_user_ac_submissions GROUP BY contestant_handle) AS t1
            ON t1.contestant_handle = handle
        LEFT JOIN (SELECT contestant_handle, COUNT(*) AS submissions FROM vw_user_submissions GROUP BY contestant_handle) AS t2
            ON t2.contestant_handle = handle
        WHERE contestant.handle != p_handle
        LIMIT lm OFFSET ofs;

    ELSEIF filt = 'friends' THEN
        -- Count total records
        SELECT COUNT(*) AS records
        FROM contestant
        LEFT JOIN (SELECT contestant_handle, COUNT(*) AS ACSubmissions FROM vw_user_ac_submissions GROUP BY contestant_handle) AS t1
            ON t1.contestant_handle = handle
        LEFT JOIN (SELECT contestant_handle, COUNT(*) AS submissions FROM vw_user_submissions GROUP BY contestant_handle) AS t2
            ON t2.contestant_handle = handle
        WHERE contestant.handle != p_handle AND is_friend(handle, p_handle) = 1;

        -- Retrieve user summary (only friends)
        SELECT handle, 
            IFNULL(submissions, 0) AS submissions, 
            IFNULL(ACSubmissions, 0) AS ACSubmissions,
            get_days_from_last_submission(handle) AS lastSubmissionDaysAgo, 
            is_friend(handle, p_handle) AS isFriend
        FROM contestant
        LEFT JOIN (SELECT contestant_handle, COUNT(*) AS ACSubmissions FROM vw_user_ac_submissions GROUP BY contestant_handle) AS t1
            ON t1.contestant_handle = handle
        LEFT JOIN (SELECT contestant_handle, COUNT(*) AS submissions FROM vw_user_submissions GROUP BY contestant_handle) AS t2
            ON t2.contestant_handle = handle
        WHERE contestant.handle != p_handle AND is_friend(handle, p_handle) = 1
        LIMIT lm OFFSET ofs;
    END IF;
END $$
DELIMITER ;


/*
    Retrieves user summaries based on a search query for handles.

    - `searchHandle` → Prefix match for user handles.
    - `p_handle` → The user performing the search (excluded from results).
    - Supports pagination using `lm` (limit) and `ofs` (offset).
*/
DROP PROCEDURE IF EXISTS get_user_summary_by_handle;
DELIMITER $$
CREATE PROCEDURE get_user_summary_by_handle(
    IN p_handle VARCHAR(20), 
    IN searchHandle VARCHAR(20), 
    IN lm INT, 
    IN ofs INT
)
BEGIN
    -- Count total matching records
    SELECT COUNT(*) AS records
    FROM contestant
    LEFT JOIN (SELECT contestant_handle, COUNT(*) AS ACSubmissions FROM vw_user_ac_submissions GROUP BY contestant_handle) AS t1
        ON t1.contestant_handle = handle
    LEFT JOIN (SELECT contestant_handle, COUNT(*) AS submissions FROM vw_user_submissions GROUP BY contestant_handle) AS t2
        ON t2.contestant_handle = handle
    WHERE contestant.handle != p_handle 
    AND contestant.handle LIKE CONCAT(searchHandle, '%');

    -- Retrieve matching user summaries
    SELECT handle, 
           IFNULL(submissions, 0) AS submissions, 
           IFNULL(ACSubmissions, 0) AS ACSubmissions,
           get_days_from_last_submission(handle) AS lastSubmissionDaysAgo, 
           is_friend(handle, p_handle) AS isFriend
    FROM contestant
    LEFT JOIN (SELECT contestant_handle, COUNT(*) AS ACSubmissions FROM vw_user_ac_submissions GROUP BY contestant_handle) AS t1
        ON t1.contestant_handle = handle
    LEFT JOIN (SELECT contestant_handle, COUNT(*) AS submissions FROM vw_user_submissions GROUP BY contestant_handle) AS t2
        ON t2.contestant_handle = handle
    WHERE contestant.handle != p_handle 
    AND contestant.handle LIKE CONCAT(searchHandle, '%')
    LIMIT lm OFFSET ofs;
END $$
DELIMITER ;


/*
    Retrieves a user's AC (Accepted) submission statistics.

    - `TotalAC` → Count of distinct problems solved (Accepted submissions).
    - `TotalRecentAC` → Count of distinct problems solved in the last 30 days.
    - `TotalSubmissions` → Total number of submissions made.
*/
DROP PROCEDURE IF EXISTS get_AC_statistics;
DELIMITER $$
CREATE PROCEDURE get_AC_statistics(IN in_contestant_handle VARCHAR(255))
BEGIN
    SELECT 
        COUNT(DISTINCT CASE WHEN status = 'AC' THEN Problem_id END) AS TotalAC,
        COUNT(DISTINCT CASE WHEN status = 'AC' AND `date` >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN Problem_id END) AS TotalRecentAC,
        COUNT(*) AS TotalSubmissions
    FROM JUDGE_DB.SUBMISSION
    WHERE contestant_handle = in_contestant_handle;
END $$
DELIMITER ;
