USE JUDGE_DB;


DROP PROCEDURE IF EXISTS sp_create_friend;
DELIMITER $$
CREATE PROCEDURE sp_create_friend( IN p_contestant_handle VARCHAR(255),  IN p_friend_handle VARCHAR(255))
BEGIN
    INSERT INTO JUDGE_DB.FRIENDSHIP (contestant_handle, friend_handle) 
    VALUES (p_contestant_handle, p_friend_handle);
END $$

DELIMITER ;


DROP PROCEDURE IF EXISTS sp_delete_friend;
DELIMITER $$

CREATE PROCEDURE sp_delete_friend(
    IN p_contestant_handle VARCHAR(255),
    IN p_friend_handle VARCHAR(255)
)
BEGIN
    DELETE FROM JUDGE_DB.FRIENDSHIP 
    WHERE contestant_handle = p_contestant_handle 
    AND friend_handle = p_friend_handle;
END $$

DELIMITER ;
