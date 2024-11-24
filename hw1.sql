select datname from pg_database;

-- таблица courses
CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    is_exam BOOLEAN NOT NULL,
    min_grade INT NOT NULL,
    max_grade INT NOT NULL
);

INSERT INTO courses (name, is_exam, min_grade, max_grade)
VALUES 
    ('Geometry', TRUE, 0, 100),
    ('Algebra', FALSE, 0, 50),
    ('Physics', TRUE, 0, 100),
    ('Machine learning', FALSE, 0, 50);

SELECT * FROM courses LIMIT 10;

-- таблица groups
CREATE TABLE groups (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    short_name VARCHAR(10) NOT NULL,
    students_ids INT[] 
);

INSERT INTO groups (full_name, short_name, students_ids)
VALUES 
    ('237-100-о(м)-1', '1', ARRAY[1, 3]),
    ('237-100-о(м)-2', '2', ARRAY[2, 4]);

-- таблица students
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    group_id INT NOT NULL REFERENCES groups(id),
    courses_ids INT[] 
);

INSERT INTO students (first_name, last_name, group_id, courses_ids)
VALUES 
    ('Alice', 'Smith', 1, ARRAY[1, 3]),
    ('Bob', 'Johnson', 1, ARRAY[1, 3]),
    ('Charlie', 'Brown', 2, ARRAY[2, 4]),
    ('Diana', 'Jones', 2, ARRAY[2, 4]);

-- создание таблицы grades
CREATE TABLE grades (
    student_id INT NOT NULL REFERENCES students(id),
    grade INT NOT NULL,
    grade_str VARCHAR(20) NOT NULL,
    course_id INT NOT NULL REFERENCES courses(id)
);

INSERT INTO grades (student_id, grade, grade_str, course_id)
VALUES 
    (1, 90, 'Excellent', 1), 
    (1, 80, 'Good', 3),      
    (2, 70, 'Good', 1),      
    (2, 65, 'Good', 3),      
    (3, 40, 'Pass', 2),      
    (3, 45, 'Good', 4),      
    (4, 35, 'Pass', 2),      
    (4, 50, 'Excellent', 4); 
	
-- все курсы, по которым есть экзамен
SELECT *
FROM courses
WHERE is_exam = TRUE
LIMIT 10;

-- общее количество курсов
SELECT COUNT(*) AS total_courses
FROM courses
LIMIT 10;

-- группы где больше одного студента
SELECT *
FROM groups
WHERE ARRAY_LENGTH(students_ids, 1) > 1
LIMIT 10;

-- общее кол-во групп
SELECT COUNT(*) AS total_groups
FROM groups
LIMIT 10;

-- все оценки выше 80
SELECT *
FROM grades
WHERE grade > 80
LIMIT 10;

-- средняя оценка по всем курсам
SELECT AVG(grade) AS average_grade
FROM grades
LIMIT 10;

-- вывод студента с максимальной оценкой
SELECT s.first_name, s.last_name, g.grade, c.name AS course_name
FROM grades g
JOIN students s ON g.student_id = s.id
JOIN courses c ON g.course_id = c.id
WHERE g.grade = (SELECT MAX(grade) FROM grades)
LIMIT 1;




