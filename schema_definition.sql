-- -----------------------------------------------------
-- Schema JUDGE_DB
-- -----------------------------------------------------

DROP TABLE IF EXISTS JUDGE_DB.FRIENDSHIP ;
DROP TABLE IF EXISTS JUDGE_DB.ADMIN ;
DROP TABLE IF EXISTS JUDGE_DB.TEST ;
DROP TABLE IF EXISTS JUDGE_DB.SUBMISSION ;
DROP TABLE IF EXISTS JUDGE_DB.CONTESTANT ;
DROP TABLE IF EXISTS JUDGE_DB.PROBLEM ;
DROP TABLE IF EXISTS JUDGE_DB.PROBLEMSETTER ;
DROP TABLE IF EXISTS JUDGE_DB.USER ;

CREATE SCHEMA IF NOT EXISTS JUDGE_DB DEFAULT CHARACTER SET utf8 ;
USE JUDGE_DB ;

-- -----------------------------------------------------
-- Table JUDGE_DB.USER
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS JUDGE_DB.USER (
  handle VARCHAR(20) NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  password VARCHAR(100) NOT NULL,
  PRIMARY KEY (handle))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table JUDGE_DB.PROBLEMSETTER
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS JUDGE_DB.PROBLEMSETTER (
  handle VARCHAR(20) NOT NULL,
  PRIMARY KEY (handle),
  CONSTRAINT fk_PROBLEMSETTER_USER1
    FOREIGN KEY (handle)
    REFERENCES JUDGE_DB.USER (handle)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table JUDGE_DB.PROBLEM
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS JUDGE_DB.PROBLEM (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NOT NULL,
  statement TEXT NOT NULL,
  editorial TEXT NULL,
  time_limit_seconds INT NOT NULL,
  memory_limit_mb INT NOT NULL,
  problemsetter_handle VARCHAR(20) NOT NULL,
  PRIMARY KEY (id),
  INDEX fk_PROBLEM_PROBLEMSETTER1_idx (problemsetter_handle ASC) VISIBLE,
  CONSTRAINT fk_PROBLEM_PROBLEMSETTER1
    FOREIGN KEY (problemsetter_handle)
    REFERENCES JUDGE_DB.PROBLEMSETTER (handle)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table JUDGE_DB.CONTESTANT
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS JUDGE_DB.CONTESTANT (
  handle VARCHAR(20) NOT NULL,
  PRIMARY KEY (handle),
  CONSTRAINT fk_CONTESTANT_USER1
    FOREIGN KEY (handle)
    REFERENCES JUDGE_DB.USER (handle)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table JUDGE_DB.SUBMISSION
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS JUDGE_DB.SUBMISSION (
  id INT NOT NULL AUTO_INCREMENT,
  status ENUM('QU', 'AC', 'WA', 'TL', 'RT', 'CE') NOT NULL DEFAULT 'QU',
  execution_time_seconds DECIMAL(4,3) NOT NULL,
  date DATETIME NOT NULL,
  code TEXT NOT NULL,
  problem_id INT NOT NULL,
  contestant_handle VARCHAR(20) NOT NULL,
  PRIMARY KEY (id),
  INDEX fk_Submission_Problem1_idx (problem_id ASC) VISIBLE,
  INDEX fk_SUBMISSION_CONTESTANT1_idx (contestant_handle ASC) VISIBLE,
  CONSTRAINT fk_Submission_Problem1
    FOREIGN KEY (problem_id)
    REFERENCES JUDGE_DB.PROBLEM (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_SUBMISSION_CONTESTANT1
    FOREIGN KEY (contestant_handle)
    REFERENCES JUDGE_DB.CONTESTANT (handle)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table JUDGE_DB.TEST
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS JUDGE_DB.TEST (
  number INT NOT NULL,
  Problem_id INT NOT NULL,
  input TEXT NOT NULL,
  output TEXT NOT NULL,
  PRIMARY KEY (number, Problem_id),
  INDEX fk_Test_Problem1_idx (Problem_id ASC) VISIBLE,
  CONSTRAINT fk_Test_Problem1
    FOREIGN KEY (Problem_id)
    REFERENCES JUDGE_DB.PROBLEM (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table JUDGE_DB.ADMIN
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS JUDGE_DB.ADMIN (
  handle VARCHAR(20) NOT NULL,
  PRIMARY KEY (handle),
  CONSTRAINT fk_ADMIN_USER1
    FOREIGN KEY (handle)
    REFERENCES JUDGE_DB.USER (handle)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table JUDGE_DB.FRIENDSHIP
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS JUDGE_DB.FRIENDSHIP (
  contestant_handle VARCHAR(20) NOT NULL,
  friend_handle VARCHAR(20) NOT NULL,
  PRIMARY KEY (contestant_handle, friend_handle),
  INDEX fk_CONTESTANT_has_CONTESTANT_CONTESTANT2_idx (friend_handle ASC) VISIBLE,
  INDEX fk_CONTESTANT_has_CONTESTANT_CONTESTANT1_idx (contestant_handle ASC) VISIBLE,
  CONSTRAINT fk_CONTESTANT_has_CONTESTANT_CONTESTANT1
    FOREIGN KEY (contestant_handle)
    REFERENCES JUDGE_DB.CONTESTANT (handle)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_CONTESTANT_has_CONTESTANT_CONTESTANT2
    FOREIGN KEY (friend_handle)
    REFERENCES JUDGE_DB.CONTESTANT (handle)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- User definition
-- -----------------------------------------------------

DROP USER IF EXISTS 'application'@'localhost';
CREATE USER 'application'@'localhost' IDENTIFIED BY 'Str0ngP@ssword!';

GRANT ALL ON  JUDGE_DB.* TO 'application'@'localhost';