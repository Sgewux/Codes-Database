USE JUDGE_DB;

-- -----------------------------------------------------
-- Friends
-- -----------------------------------------------------

/*
    Establishes a friendship between two contestants by inserting a new record into 
    the `FRIENDSHIP` table.
*/
DROP PROCEDURE IF EXISTS create_friend;
DELIMITER $$
CREATE PROCEDURE create_friend( 
    IN p_contestant_handle VARCHAR(255),  
    IN p_friend_handle VARCHAR(255)
)
BEGIN
    INSERT INTO JUDGE_DB.FRIENDSHIP (contestant_handle, friend_handle) 
    VALUES (p_contestant_handle, p_friend_handle);
END $$
DELIMITER ;


/*
    Removes a friendship between two contestants by deleting the corresponding record 
    from the `FRIENDSHIP` table.
*/
DROP PROCEDURE IF EXISTS delete_friend;
DELIMITER $$
CREATE PROCEDURE delete_friend(
    IN p_contestant_handle VARCHAR(255),
    IN p_friend_handle VARCHAR(255)
)
BEGIN
    DELETE FROM JUDGE_DB.FRIENDSHIP 
    WHERE contestant_handle = p_contestant_handle 
    AND friend_handle = p_friend_handle;
END $$
DELIMITER ;
