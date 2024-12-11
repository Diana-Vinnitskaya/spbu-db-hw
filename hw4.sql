CREATE TABLE IF NOT EXISTS employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    manager_id INT REFERENCES employees(employee_id)
);

-- Пример данных
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Frank Miller', 'Intern', 'IT', 35000, 5);

SELECT * FROM employees LIMIT 5;

CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

-- Пример данных
INSERT INTO products (name, price)
VALUES
    ('Product A', 150.00),
    ('Product B', 200.00),
    ('Product C', 100.00);

CREATE TABLE IF NOT EXISTS sales(
    sale_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    product_id INT REFERENCES products(product_id),
    quantity INT NOT NULL,
    sale_date DATE NOT NULL
);

-- Пример данных
INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES
    (2, 1, 20, '2024-10-15'),
    (2, 2, 15, '2024-10-16'),
    (3, 1, 10, '2024-10-17'),
    (3, 3, 5, '2024-10-20'),
    (4, 2, 8, '2024-10-21'),
    (2, 1, 12, '2024-11-01');

SELECT * FROM sales LIMIT 5;

-- 1. Создать триггеры со всеми возможными ключевыми словами, а также рассмотреть операционные триггеры

-- Пример №1
-- Таблица для хранения информации о удаленных сотрудниках
CREATE TABLE IF NOT EXISTS deleted_employees (
    employee_id INT,
    name VARCHAR(50),
    position VARCHAR(50),
    department VARCHAR(50),
    salary NUMERIC(10, 2),
    deleted_at TIMESTAMP
);

-- Функция для записи удаленных данных
CREATE OR REPLACE FUNCTION log_deleted_employee()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Deleted employee: %', OLD.employee_id;
    INSERT INTO deleted_employees (employee_id, name, position, department, salary, deleted_at)
    VALUES (OLD.employee_id, OLD.name, OLD.position, OLD.department, OLD.salary, CURRENT_TIMESTAMP);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- AFTER DELETE триггер
CREATE TRIGGER after_delete_employee
AFTER DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_deleted_employee();

-- Проверка
DELETE FROM employees WHERE employee_id = 6;

SELECT * FROM employees WHERE employee_id = 6;

SELECT * FROM deleted_employees WHERE employee_id = 6;

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Frank Miller', 'Intern', 'IT', 35000, 5);

-- Пример №2
-- Функция для каскадного удаления всех записей из таблицы sales, связанных с удаляемым сотрудником
CREATE OR REPLACE FUNCTION cascade_delete_sales()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM sales WHERE employee_id = OLD.employee_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- BEFORE DELETE триггер
CREATE TRIGGER before_delete_employee_sales
BEFORE DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION cascade_delete_sales();

-- Проверка
DELETE FROM employees WHERE employee_id = 4;
SELECT * FROM sales LIMIT 10;

-- Пример №3
-- Функция для расчета бонуса
CREATE OR REPLACE FUNCTION calculate_bonus()
RETURNS TRIGGER AS $$
BEGIN
    -- Бонус равен 10% от зарплаты
    NEW.bonus := NEW.salary * 0.10;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- BEFORE INSERT триггер
CREATE TRIGGER before_insert_bonus
BEFORE INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION calculate_bonus();

-- BEFORE UPDATE триггер
CREATE TRIGGER before_update_bonus
BEFORE UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION calculate_bonus();

-- Добавляем колонку bonus
ALTER TABLE employees 
ADD COLUMN bonus NUMERIC(10, 2);

-- Заполняем колонку bonus
UPDATE employees
SET bonus = salary * 0.10;

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Frank Miller', 'Intern', 'IT', 35000, 5);

SELECT * FROM employees LIMIT 15;

-- 2. Попрактиковаться в созданиях транзакций (привести пример успешной и фейл транзакции, объяснить в комментариях почему она зафейлилась)
-- Пример успешной транзакции
BEGIN;

-- Добавляем нового сотрудника
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('John Doe', 'Marketing Manager', 'Marketing', 90000, NULL);

-- Добавляем продажу, связанную с этим сотрудником
INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES ((SELECT employee_id FROM employees WHERE name = 'John Doe'), 1, 25, '2024-11-02');

COMMIT;

-- Пример фейл транзацкии(ошибка внешнего ключа), транзакция не пройдет т.к. мы указываем не существующий product_id
BEGIN;

-- Добавляем нового сотрудника
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('Jane Doe', 'Marketing Assistant', 'Marketing', 50000, NULL);

-- Попытка добавить продажу с несуществующим продуктом (ошибка внешнего ключа)
INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES ((SELECT employee_id FROM employees WHERE name = 'Jane Doe'), 9, 10, '2024-11-03');

COMMIT;
ROLLBACK;

-- 3. Использовать RAISE для логирования
-- Пример (разные сообщения при разных действиях INSERT/UPDATE/DELETE)
-- Создаём функцию для логирования
CREATE OR REPLACE FUNCTION log_employee_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        RAISE NOTICE 'Добавлен новый сотрудник: %', NEW.name;
    ELSIF TG_OP = 'UPDATE' THEN
        RAISE NOTICE 'Обновлены данные сотрудника ID: %, Новая зарплата: %', NEW.employee_id, NEW.salary;
    ELSIF TG_OP = 'DELETE' THEN
        RAISE NOTICE 'Удалён сотрудник ID: %, Имя: %', OLD.employee_id, OLD.name;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- BEFORE INSERT триггер
CREATE TRIGGER log_employee_insert
BEFORE INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_changes();

-- AFTER UPDATE триггер
CREATE TRIGGER log_employee_update
AFTER UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_changes();

-- BEFORE DELETE триггер
CREATE TRIGGER log_employee_delete
BEFORE DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_changes();

-- Проверка
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('Jane Doe', 'Marketing Assistant', 'Marketing', 50000, NULL);

