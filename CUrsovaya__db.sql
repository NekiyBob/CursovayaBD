
CREATE TABLE hotels (
    hotel_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    inn CHAR(10) UNIQUE NOT NULL,
    director VARCHAR(100),
    owner VARCHAR(100),
    address TEXT NOT NULL,
    phone VARCHAR(20)
);
CREATE TABLE positions (
    position_id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);
CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    hotel_id INT REFERENCES hotels(hotel_id) ON DELETE CASCADE,
    inn CHAR(10) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    position_id INT REFERENCES positions(position_id),
    hire_date DATE DEFAULT CURRENT_DATE,
    salary NUMERIC(10,2) CHECK (salary >= 0)
);
CREATE TABLE rooms (
    room_id SERIAL PRIMARY KEY,
    hotel_id INT REFERENCES hotels(hotel_id) ON DELETE CASCADE,
    description TEXT,
    beds SMALLINT CHECK (beds > 0),
    price_per_day NUMERIC(10,2) CHECK (price_per_day > 0),
    status VARCHAR(20) DEFAULT 'работает' CHECK (status IN ('работает','ремонт'))
);
CREATE TABLE guests (
    guest_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    passport VARCHAR(15) UNIQUE NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100)
);
CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    room_id INT REFERENCES rooms(room_id) ON DELETE CASCADE,
    guest_id INT REFERENCES guests(guest_id) ON DELETE CASCADE,
    arrival_date DATE NOT NULL,
    departure_date DATE NOT NULL,
    advance NUMERIC(10,2) DEFAULT 0 CHECK (advance >= 0),
    CHECK (arrival_date < departure_date)
);

CREATE TABLE stays (
    stay_id SERIAL PRIMARY KEY,
    room_id INT REFERENCES rooms(room_id),
    guest_id INT REFERENCES guests(guest_id),
    checkin_date DATE NOT NULL,
    checkout_date DATE,
    total_cost NUMERIC(10,2),
    CHECK (checkout_date IS NULL OR checkin_date < checkout_date)
);
--Все свободные номера на сегодня
CREATE VIEW free_rooms AS
SELECT r.room_id, r.description, r.beds, r.price_per_day
FROM rooms r
WHERE r.status = 'работает'
AND r.room_id NOT IN (
    SELECT b.room_id FROM bookings b
    WHERE CURRENT_DATE BETWEEN b.arrival_date AND b.departure_date
);
--Количество занятых и свободных номеров
CREATE VIEW room_status_summary AS
SELECT 
    h.name AS hotel,
    COUNT(r.room_id) FILTER (WHERE r.status = 'работает') AS available,
    COUNT(r.room_id) FILTER (WHERE r.status = 'ремонт') AS under_repair
FROM hotels h
JOIN rooms r ON h.hotel_id = r.hotel_id
GROUP BY h.name;
-- свободные ноемра на дату
SELECT * FROM free_rooms WHERE price_per_day < 5000;
--количество занятых номеров на сегодня
SELECT COUNT(*) AS occupied_rooms
FROM bookings
WHERE CURRENT_DATE BETWEEN arrival_date AND departure_date;
--количество посетителей за период 
SELECT COUNT(DISTINCT guest_id) AS guests_count
FROM stays
WHERE checkin_date BETWEEN '2025-10-01' AND '2025-10-31';


SET search_path = hotel

