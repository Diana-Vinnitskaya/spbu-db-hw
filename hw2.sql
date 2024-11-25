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
    ('Charlie', 'Brown', 1, ARRAY[1, 3]),
    ('Diana', 'Jones', 2, ARRAY[2, 4]),
	('Billy', 'Joel', 2, ARRAY[2, 4]),
	('Michael', 'Jackson', 2, ARRAY[2, 4]);

-- создание таблицы grades
CREATE TABLE grades (
    student_id INT NOT NULL REFERENCES students(id),
    grade INT NOT NULL,
    grade_str VARCHAR(20) NOT NULL,
    course_id INT NOT NULL REFERENCES courses(id)
);

INSERT INTO grades (student_id, grade, grade_str, course_id)
VALUES 
    (1, 92, 'Excellent', 1), 
    (1, 80, 'Good', 3),      
    (2, 75, 'Good', 1),      
    (2, 95, 'Excellent', 3), 
    (3, 40, 'Pass', 1),      
    (3, 55, 'Pass', 3),      
    (4, 30, 'Pass', 2),      
    (4, 50, 'Excellent', 4),
	(5, 48, 'Excellent', 2),      
    (5, 40, 'Good', 4),
	(6, 45, 'Good', 2),      
    (6, 50, 'Excellent', 4)
; 

-- создание промежуточной таблицы, показывающей связь студенты-курсы
CREATE TABLE student_courses (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(id),
    course_id INT NOT NULL REFERENCES courses(id),
    UNIQUE (student_id, course_id) 
);

INSERT INTO student_courses (student_id, course_id)
VALUES 
    (1, 1), (1, 3),
    (2, 1), (2, 3), 
    (3, 1), (3, 3), 
	(4, 2), (4, 4),
	(5, 2), (5, 4),
    (6, 2), (6, 4); 

-- создание промежуточной таблицы, показывающей связь группы-курсы
CREATE TABLE group_courses (
    id SERIAL PRIMARY KEY,
    group_id INT NOT NULL REFERENCES groups(id),
    course_id INT NOT NULL REFERENCES courses(id),
    UNIQUE (group_id, course_id)
);

INSERT INTO group_courses (group_id, course_id)
VALUES 
    (1, 1), (1, 3), 
    (2, 2), (2, 4);

ALTER TABLE students
DROP COLUMN courses_ids;

SELECT * FROM students LIMIT 10;

ALTER TABLE groups
DROP COLUMN students_ids;

SELECT * FROM groups LIMIT 10;

/* не удаляла колонку group_id в таблице students, т.к. в задании не написано,
что нужно создавать промежуточную таблицу студенты-группы */ 

ALTER TABLE courses
ADD CONSTRAINT unique_course_name UNIQUE (name);

-- проверка запроса выше: можно увидеть что значение поля constraint_type = "UNIQUE"
SELECT *
FROM information_schema.table_constraints
WHERE table_name = 'courses';

-- создание индекса на поле group_id в таблице students
CREATE INDEX idx_students_group_id ON students(group_id);

/* объяснение влияния индексирования на производительность в запросе:
индексы - структуры данных, которые создаются для ускорения операций поиска 
и фильтрации, работают аналогично указателям в книге. 
Когда в запросе используется поле, по которому создан индекс (например, group_id), 
база данных не сканирует всю таблицу для поиска нужных строк.
Вместо этого база данных обращается к индексу, который хранит ссылки на строки, 
соответствующие критерию.
Без индексации время O(n), с индексацией О(log(n)). */

-- список всех студентов с их курсами
SELECT s.first_name, s.last_name, c.name AS course_name
FROM student_courses sc
JOIN students s ON sc.student_id = s.id
JOIN courses c ON sc.course_id = c.id
LIMIT 50;

-- студенты, у которых средняя оценка по курсам выше, чем у любого другого студента в их группе
-- используем CTE, сначала находим средние оценки по всем курсам для каждого студента (1-ый WITH)
-- затем из полученного результата, достаем максимум для каждой группы (2-ой WITH)
-- в основном запросе делаем JOIN сначала для получения данных о студентах (имя, фамилия), 
-- а затем для получения только тех студентов, чья средняя оценка является максимальной.

WITH avg_grades_per_student AS (
    SELECT s.id AS student_id, s.group_id, AVG(g.grade) AS avg_grade
    FROM grades g
    JOIN students s ON g.student_id = s.id
    GROUP BY s.id
), 
group_max_avg AS (
    SELECT group_id, MAX(avg_grade) AS max_avg_grade
    FROM avg_grades_per_student
    GROUP BY group_id
)
SELECT s.first_name, s.last_name, agps.avg_grade
FROM avg_grades_per_student agps
JOIN students s ON agps.student_id = s.id
JOIN group_max_avg gma ON agps.group_id = gma.group_id AND agps.avg_grade = gma.max_avg_grade
LIMIT 10;


-- количество студентов на каждом курсе
SELECT c.name AS course_name, COUNT(sc.student_id) AS student_count
FROM student_courses sc
JOIN courses c ON sc.course_id = c.id
GROUP BY c.name
LIMIT 10;

-- средняя оценка на каждом курсе
SELECT c.name AS course_name, AVG(g.grade) AS avg_grade
FROM grades g
JOIN courses c ON g.course_id = c.id
GROUP BY c.name
LIMIT 10;