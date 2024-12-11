-- Данная база данных описывает структуру авиакомпании, включающую следующие таблицы:

-- airplanes — таблица, содержащая информацию о самолетах авиакомпании.
-- Включает данные о модели, вместимости, производителе, годе выпуска и авиакомпании-владельце.

-- flights() — таблица, содержащая информацию о рейсах.
-- Включает данные о номере рейса, времени вылета и прилета, аэропортах вылета и прилета, а также статусе рейса.

-- passengers() — таблица с информацией о пассажирах.
-- Включает данные о имени, фамилии, электронной почте и номере телефона пассажира.

-- reservations() — таблица, содержащая данные о бронированиях.
-- Включает информацию о рейсе, пассажире, номере места и статусе бронирования.

-- payments() — таблица, содержащая информацию о платежах.
-- Включает данные о сумме платежа, методе оплаты и дате платежа для каждого бронирования.

-- airports() — таблица, содержащая информацию об аэропортах.
-- Включает данные о названии аэропорта, городе и стране его расположения.


-- Таблица airplanes
CREATE TABLE IF NOT EXISTS airplanes (
    airplane_id SERIAL PRIMARY KEY,
    model VARCHAR(50) NOT NULL,
    seating_capacity INT NOT NULL CHECK (seating_capacity > 0),  -- Проверка на неотрицательность
    manufacturer VARCHAR(50) NOT NULL,
    year_of_manufacture INT NOT NULL CHECK (year_of_manufacture > 1900),  -- Проверка на корректность года
    airline VARCHAR(50) NOT NULL DEFAULT 'Unknown Airline'  -- Значение по умолчанию
);

-- Данные для таблицы airplanes
INSERT INTO airplanes (model, seating_capacity, manufacturer, year_of_manufacture, airline)
VALUES 
    ('Boeing 737', 180, 'Boeing', 2015, 'Aeroflot'),
    ('Airbus A320', 150, 'Airbus', 2018, 'S7 Airlines'),
    ('Boeing 787', 250, 'Boeing', 2020, 'Aeroflot'),
    ('Airbus A350', 300, 'Airbus', 2022, 'Ural Airlines'),
    ('Boeing 777', 350, 'Boeing', 2017, 'Aeroflot');

SELECT * FROM airplanes LIMIT 10;

-- Таблица flights
CREATE TABLE IF NOT EXISTS flights (
    flight_id SERIAL PRIMARY KEY,
    airplane_id INT NOT NULL REFERENCES airplanes(airplane_id) ON DELETE CASCADE,  -- Обработка DELETE
    flight_number VARCHAR(10) NOT NULL,
    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL CHECK (arrival_time > departure_time),  -- Проверка, что время прибытия больше времени вылета
    departure_airport VARCHAR(100) NOT NULL,
    arrival_airport VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'Scheduled'  -- Статус по умолчанию
);

-- Данные для таблицы flights
INSERT INTO flights (airplane_id, flight_number, departure_time, arrival_time, departure_airport, arrival_airport, status)
VALUES 
    (1, 'SU123', '2024-12-01 14:00:00', '2024-12-01 16:00:00', 'Sheremetyevo', 'Pulkovo', 'Scheduled'),
    (2, 'S7011', '2024-12-01 09:30:00', '2024-12-01 12:00:00', 'Domodedovo', 'Vnukovo', 'Delayed'),
    (3, 'SU456', '2024-12-02 17:00:00', '2024-12-02 19:30:00', 'Vnukovo', 'Sheremetyevo', 'Cancelled'),
    (4, 'U1987', '2024-12-05 10:00:00', '2024-12-05 12:30:00', 'Sheremetyevo', 'Vnukovo', 'Scheduled'),
    (5, 'SU789', '2024-12-03 15:00:00', '2024-12-03 17:30:00', 'Pulkovo', 'Vnukovo', 'Scheduled');

SELECT * FROM flights LIMIT 10;

-- Таблица passengers
CREATE TABLE IF NOT EXISTS passengers (
    passenger_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,  -- Проверка уникальности
    phone_number VARCHAR(20) 
);

-- Данные для таблицы passengers
INSERT INTO passengers (first_name, last_name, email, phone_number)
VALUES 
    ('John', 'Doe', 'john.doe@gmail.com', '+1234567890'),
    ('Jane', 'Smith', 'jane.smith@gmail.com', '+0987654321'),
    ('Alice', 'Johnson', 'alice.johnson@gmail.com', '+1112233445'),
    ('Bob', 'Williams', 'bob.williams@gmail.com', '+1222333445'),
    ('Charlie', 'Brown', 'charlie.brown@gmail.com', '+1333444555');

SELECT * FROM passengers LIMIT 10;

-- Таблица reservations
CREATE TABLE IF NOT EXISTS reservations (
    reservation_id SERIAL PRIMARY KEY,
    flight_id INT NOT NULL REFERENCES flights(flight_id) ON DELETE CASCADE,  -- Обработка DELETE
    passenger_id INT NOT NULL REFERENCES passengers(passenger_id) ON DELETE CASCADE,  -- Обработка DELETE
    reservation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Дата бронирования по умолчанию
    seat_number VARCHAR(5) NOT NULL,
    status VARCHAR(20) DEFAULT 'Confirmed'  -- Статус бронирования по умолчанию
);

-- Данные для таблицы reservations
INSERT INTO reservations (flight_id, passenger_id, seat_number, status)
VALUES 
    (1, 1, '12A', 'Confirmed'),
    (2, 2, '5B', 'Cancelled'),
    (3, 3, '7C', 'Confirmed'),
    (4, 4, '3D', 'Confirmed'),
    (5, 5, '8E', 'Confirmed'),
	(1, 5, '8F', 'Confirmed'),
	(3, 5, '8D', 'Cancelled'),
	(1, 3, '2F', 'Confirmed');

SELECT * FROM reservations LIMIT 10;

-- Таблица payments
CREATE TABLE IF NOT EXISTS payments (
    payment_id SERIAL PRIMARY KEY,
    reservation_id INT NOT NULL REFERENCES reservations(reservation_id) ON DELETE CASCADE,  -- Обработка DELETE
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0), 
	payment_method VARCHAR(20) NOT NULL DEFAULT 'Credit Card',  -- Метод оплаты по умолчанию
    payment_date DATE DEFAULT CURRENT_DATE  -- Дата платежа по умолчанию
);

-- Данные для таблицы payments
INSERT INTO payments (reservation_id, amount, payment_method, payment_date)
VALUES 
    (1, 150.00, 'Credit Card', '2024-12-01'),
    (2, 200.00, 'Online Payment', '2024-12-02'),
    (3, 180.00, 'Cash', '2024-12-03'),
    (4, 250.00, 'Credit Card', '2024-12-04'),
    (5, 220.00, 'Online Payment', '2024-12-05');

SELECT * FROM payments LIMIT 10;

-- Таблица airports
CREATE TABLE IF NOT EXISTS airports (
    airport_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL
);

-- Данные для таблицы airports
INSERT INTO airports (name, city, country)
VALUES 
    ('Sheremetyevo', 'Moscow', 'Russia'),
    ('Domodedovo', 'Moscow', 'Russia'),
    ('Pulkovo', 'Saint Petersburg', 'Russia'),
    ('Vnukovo', 'Moscow', 'Russia'),
    ('Sochi International', 'Sochi', 'Russia');

SELECT * FROM airports LIMIT 10;

-- Примеры запросов

-- Количество бронирований для каждого рейса
SELECT f.flight_number, COUNT(r.reservation_id) AS number_of_reservations
FROM flights f
LEFT JOIN reservations r ON f.flight_id = r.flight_id
GROUP BY f.flight_number;

-- Общая суммы платежей по каждому рейсу
SELECT 
    f.flight_number, 
    SUM(p.amount) AS total_payments
FROM payments p
JOIN reservations r ON p.reservation_id = r.reservation_id
JOIN flights f ON r.flight_id = f.flight_id
GROUP BY f.flight_number;

--  Количество рейсов, выполняемых каждым самолетом
SELECT 
    a.model AS airplane_model, 
    COUNT(f.flight_id) AS number_of_flights
FROM flights f
JOIN airplanes a ON f.airplane_id = a.airplane_id
GROUP BY a.model;

-- Средняя вместимость самолетов для каждой авиакомпании
SELECT 
    a.airline, 
    AVG(a.seating_capacity) AS average_seating_capacity
FROM airplanes a
GROUP BY a.airline;

-- Список всех пассажиров, которые не оплатили бронирование
SELECT 
    p.first_name, 
    p.last_name, 
    p.email
FROM passengers p
LEFT JOIN reservations r ON p.passenger_id = r.passenger_id
LEFT JOIN payments pay ON r.reservation_id = pay.reservation_id
WHERE pay.payment_id IS NULL;

-- Рейсы, которые были задержаны на более чем 2 часа
SELECT 
    f.flight_number, 
    f.departure_time, 
    f.arrival_time, 
    (f.arrival_time - f.departure_time) AS delay
FROM flights f
WHERE f.status = 'Delayed' 
AND (f.arrival_time - f.departure_time) > INTERVAL '2 hours';

