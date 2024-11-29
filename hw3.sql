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
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Frank Miller', 'Intern', 'IT', 35000, 5);

SELECT * FROM employees LIMIT 5;

CREATE TABLE IF NOT EXISTS sales(
    sale_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    sale_date DATE NOT NULL
);

-- Пример данных
INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES
    (1, 1, 15, '2024-11-08'),
	(1, 2, 25, '2024-10-09'),
	(1, 3, 20, '2024-11-10'),
	(2, 1, 10, '2024-11-11'),
	(2, 2, 5, '2024-10-12'),
	(2, 3, 8, '2024-11-23'),
	(3, 1, 7, '2024-11-24'),
	(3, 2, 12, '2024-10-15'),
	(3, 3, 14, '2024-10-16'),
	(4, 1, 18, '2024-11-27'),
	(4, 2, 20, '2024-11-28'),
	(4, 3, 11, '2024-11-19')

SELECT * FROM sales LIMIT 5;

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

SELECT * FROM products LIMIT 3;

-- Создайте временную таблицу high_sales_products, которая будет содержать продукты, проданные в количестве более 10 единиц за последние 7 дней.
-- Выведите данные из таблицы high_sales_products.
CREATE TEMP TABLE high_sales_products AS
SELECT p.product_id, p.name, SUM(s.quantity) AS total_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
WHERE s.sale_date > CURRENT_DATE - INTERVAL '7 days'
GROUP BY p.product_id, p.name
HAVING SUM(s.quantity) > 10;

SELECT * FROM high_sales_products LIMIT 10;

-- Создайте CTE employee_sales_stats, который посчитает общее количество продаж и среднее количество продаж для каждого сотрудника за последние 30 дней.
-- Напишите запрос, который выводит сотрудников с количеством продаж выше среднего по компании.
WITH employee_sales_stats AS (
    SELECT employee_id, SUM(quantity) AS total_sales, AVG(s.quantity) AS avg_quantity
    FROM sales s
    WHERE s.sale_date >= CURRENT_DATE - INTERVAL '30 days'
	GROUP BY s.employee_id
),
company_average AS (
    SELECT 
        AVG(total_sales) AS company_avg_sales
    FROM 
        employee_sales_stats
)
SELECT e.name, e.position, stats.total_sales, company_avg_sales
FROM 
    employee_sales_stats stats
JOIN 
    employees e ON stats.employee_id = e.employee_id,
company_average
WHERE 
    stats.total_sales > company_average.company_avg_sales
	LIMIT 10;

-- Используя CTE, создайте иерархическую структуру, показывающую всех сотрудников, которые подчиняются конкретному менеджеру.
-- Если я правильно понимаю задание, нужно построить иерархию для менеджера, которого я выбрала (например, 2)
WITH RECURSIVE employee_hierarchy AS (
    SELECT employee_id, name, position, department, salary, manager_id
    FROM employees
    WHERE employee_id = 1  --  менеджер, для которого строится иерархия (например, 1)
    
    UNION ALL
  
    -- Рекурсивная часть: выбираем сотрудников, подчинённых текущим
    SELECT e.employee_id, e.name, e.position, e.department, e.salary, e.manager_id
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM employee_hierarchy LIMIT 100;

-- Напишите запрос с CTE, который выведет топ-3 продукта по количеству продаж за текущий месяц и за прошлый месяц. В результатах должно быть указано, к какому месяцу относится каждая запись.
-- CTE для текущего месяца
WITH CurrentMonthSales AS (
    SELECT  p.product_id, p.name AS product_name, SUM(s.quantity) AS total_sales, 'Current Month' AS sales_period
    FROM 
        sales s
    JOIN 
        products p ON s.product_id = p.product_id
    WHERE 
        s.sale_date >= DATE_TRUNC('month', CURRENT_DATE) AND s.sale_date < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
    GROUP BY 
        p.product_id, p.name
    ORDER BY 
        SUM(s.quantity) DESC
    LIMIT 3
),
-- CTE для прошлого месяца
PreviousMonthSales AS (
    SELECT 
        p.product_id, p.name AS product_name, SUM(s.quantity) AS total_sales, 'Previous Month' AS sales_period
    FROM 
        sales s
    JOIN 
        products p ON s.product_id = p.product_id
    WHERE 
        s.sale_date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
        AND s.sale_date < DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY 
        p.product_id, p.name
    ORDER BY 
        SUM(s.quantity) DESC
    LIMIT 3
)
SELECT * FROM CurrentMonthSales 
UNION ALL
SELECT * FROM PreviousMonthSales
ORDER BY sales_period DESC, total_sales DESC;

-- Создайте индекс для таблицы sales по полю employee_id и sale_date, чтобы ускорить запросы, которые фильтруют данные по сотрудникам и датам.
CREATE INDEX idx_sales_employee_date ON sales(employee_id, sale_date);

-- Проверьте, как наличие индекса влияет на производительность следующего запроса, используя EXPLAIN ANALYZE.
-- Используя EXPLAIN, проанализируйте запрос, который находит общее количество проданных единиц каждого продукта.
EXPLAIN ANALYZE
SELECT product_id, SUM(quantity) AS total_quantity
FROM sales
GROUP BY product_id LIMIT 5;