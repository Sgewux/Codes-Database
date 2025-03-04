-- -----------------------------------------------------
-- Table JUDGE_DB.USER
-- -----------------------------------------------------

INSERT INTO JUDGE_DB.USER (handle, first_name, last_name, password) VALUES
('gtattersill0', 'Gwen', 'Tattersill', 'oU3`=N9KPm9'),
('jdoe1', 'John', 'Doe', 'P@ssw0rd123'),
('asmith2', 'Alice', 'Smith', 'SecureP@ss456'),
('bjohnson3', 'Bob', 'Johnson', 'Qwerty!789'),
('clopez4', 'Carlos', 'Lopez', 'Lopez_987!'),
('dgarcia5', 'Diana', 'Garcia', 'Garcia#654'),
('emartin6', 'Emma', 'Martin', 'Martin*321'),
('fwhite7', 'Frank', 'White', 'White@852'),
('gblack8', 'Grace', 'Black', 'Black&753'),
('hharris9', 'Henry', 'Harris', 'Harris$159'),
('shollyero', 'Shena', 'Hollyer', '1234');


-- -----------------------------------------------------
-- Table JUDGE_DB.CONTESTANT
-- -----------------------------------------------------

INSERT INTO JUDGE_DB.CONTESTANT(handle) VALUES 
('gtattersill0'),
('jdoe1'),
('asmith2'),
('bjohnson3'),
('clopez4'),
('dgarcia5'),
('emartin6'),
('fwhite7'),
('gblack8'),
('hharris9'),
('shollyero');


-- -----------------------------------------------------
-- Table JUDGE_DB.SUBMISSION
-- -----------------------------------------------------

INSERT INTO JUDGE_DB.SUBMISSION (status, execution_time_seconds, date, code, problem_id, contestant_handle) VALUES
('WA', 1.123, "2025-02-01", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 1, 'jusantacruzc'),
('WA', 1.123, "2025-02-01", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 2, 'jusantacruzc'),
('WA', 1.123, "2025-02-01", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 1, 'jusantacruzc'),
('WA', 1.123, "2025-02-03", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 3, 'jusantacruzc'),
('WA', 1.123, "2025-02-07", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 1, 'jusantacruzc'),
('WA', 1.123, "2025-02-13", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 1, 'jusantacruzc'),
('WA', 1.123, "2025-02-17", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 2, 'jusantacruzc'),
('WA', 1.123, "2025-02-19", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 1, 'jusantacruzc'),
('WA', 1.123, "2025-02-20", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 3, 'jusantacruzc'),
('WA', 1.123, "2025-02-20", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 1, 'jusantacruzc'),
('WA', 1.123, "2025-03-01", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 1, 'shollyero'),
('WA', 1.123, "2025-03-02", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 1, 'shollyero'),
('AC', 1.123, "2025-02-17", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 2, 'shollyero'),
('AC', 1.123, "2025-02-19", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 1, 'shollyero'),
('WA', 1.123, "2025-02-20", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 3, 'shollyero'),
('WA', 1.123, "2025-02-20", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 1, 'shollyero'),
('WA', 1.123, "2025-03-01", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 1, 'shollyero'),
('WA', 1.123, "2025-03-02", '#include <iostream>\nusing namespace std;\nint main() { cout << "Hello World"; return 0; }', 1, 'shollyero');

