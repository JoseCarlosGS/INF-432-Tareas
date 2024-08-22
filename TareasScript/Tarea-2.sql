/*Nombre: Jose Carlos Giron Solano
  Registro: 216161924
*/

CREATE DATABASE SoporteBD;
GO
use SoporteBD;
GO

CREATE TABLE customer(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	ci INT NOT NULL UNIQUE, --DOCUMENTO DE IDENTIFICACION
	date_of_birth DATE,
	"name" VARCHAR(255)
);
GO

CREATE TABLE frequent_flyer_card (
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	ffc_number INT NOT NULL,
	miles INT,
	meal_code VARCHAR(10),
	id_customer INT NOT NULL,
	FOREIGN KEY(id_customer) REFERENCES customer(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);
GO


CREATE TABLE ticket(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	ticketing_code INT NOT NULL,
	number INT NOT NULL,
	id_customer INT NOT NULL,
	FOREIGN KEY (id_customer) REFERENCES customer(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);
GO

CREATE TABLE country(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	"name" VARCHAR(100) UNIQUE
);
GO

CREATE TABLE city(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	"name" VARCHAR(100) UNIQUE,
	id_country INT NOT NULL,
	FOREIGN KEY (id_country) REFERENCES country(id)
	ON UPDATE CASCADE
	ON DELETE CASCADE
)
GO

CREATE TABLE airport(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	"name" VARCHAR(255) NOT NULL,
	id_city INT NOT NULL,
	id_country INT NOT NULL,
	FOREIGN KEY (id_city) REFERENCES city(id),
	FOREIGN KEY (id_country) REFERENCES country(id)
)
GO

CREATE TABLE plane_model(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	"description" VARCHAR(255),
	graphic VARCHAR(255),
)
GO

CREATE TABLE flight_number(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	departure_time TIME NOT NULL,
	"description" VARCHAR(255),
	"type" VARCHAR(255) NOT NULL,
	airline VARCHAR(255) NOT NULL,
	id_airport_start INT NOT NULL,
	id_airport_goal INT NOT NULL,
	id_plane_model INT,
	FOREIGN KEY(id_airport_start) REFERENCES airport(id),
	FOREIGN KEY(id_airport_goal) REFERENCES airport(id),
	FOREIGN KEY(id_plane_model) REFERENCES plane_model(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)
GO

CREATE TABLE flight_category (
    id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(255) NOT NULL UNIQUE
)
GO

CREATE TABLE flight(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	boarding_time TIME NOT NULL,
	flight_date DATE NOT NULL,
	gate VARCHAR(10) NOT NULL,
	check_in_counter VARCHAR(10) NOT NULL,
	id_flight_number INT NOT NULL,
	id_flight_category INT,
	FOREIGN KEY(id_flight_number) REFERENCES flight_number(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
    FOREIGN KEY (id_flight_category) REFERENCES flight_category(id)
)
GO

CREATE TABLE coupon(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	id_ticket INT NOT NULL,
	date_of_redemption DATE NOT NULL,
	class VARCHAR(255) NOT NULL,
	stand_by VARCHAR(255),
	meal_code VARCHAR(10),
	id_flight INT NOT NULL,
	FOREIGN KEY (id_ticket) REFERENCES ticket(id),
	FOREIGN KEY (id_flight) REFERENCES flight(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

GO
CREATE TABLE pieces_of_luggage(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	number INT NOT NULL,
	"weight" DECIMAL NOT NULL, 
	id_coupon INT NOT NULL,
	FOREIGN KEY (id_coupon) REFERENCES coupon(id)
)
GO

CREATE TABLE seat(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	size DECIMAL NOT NULL,
	number INT NOT NULL,
	"location" VARCHAR(20),
	id_plane_model INT NOT NULL,
	FOREIGN KEY (id_plane_model) REFERENCES plane_model(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)
GO

CREATE TABLE available_seat(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	id_coupon INT NOT NULL,
	id_flight INT NOT NULL,
	id_seat INT NOT NULL,
	FOREIGN KEY(id_coupon) REFERENCES coupon(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	FOREIGN KEY(id_flight) REFERENCES flight(id),
	FOREIGN KEY(id_seat) REFERENCES seat(id)
)
GO

CREATE TABLE airplane(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	registration_number VARCHAR(15) NOT NULL,
	begin_of_operation DATE NOT NULL,
	"status" VARCHAR(50),
	id_plane_model INT NOT NULL,
	FOREIGN KEY (id_plane_model) REFERENCES plane_model(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)
GO


INSERT INTO customer (ci, date_of_birth, name) VALUES
(12345678, '1980-05-15', 'John Doe'),
(23456789, '1975-11-30', 'Jane Smith'),
(34567890, '1990-02-25', 'Alice Johnson'),
(45678901, '1985-07-12', 'Bob Brown'),
(56789012, '2000-12-01', 'Charlie Davis');

INSERT INTO frequent_flyer_card (ffc_number, miles, meal_code, id_customer) VALUES
(1001, 12000, 'VEG', 1),
(1002, 15000, 'NON', 2),
(1003, 8000, 'HAL', 3),
(1004, 20000, 'VGN', 4),
(1005, 5000, 'KOS', 5);

INSERT INTO ticket (ticketing_code, number, id_customer) VALUES
(123, 1, 1),
(234, 2, 2),
(345, 3, 3),
(456, 4, 4),
(567, 5, 5);

INSERT INTO country (name) VALUES
('USA'),
('Canada'),
('UK'),
('Germany'),
('France');

INSERT INTO city (name, id_country) VALUES
('New York', 1),
('Toronto', 2),
('London', 3),
('Berlin', 4),
('Paris', 5);

INSERT INTO airport (name, id_city, id_country) VALUES
('JFK International Airport', 1, 1),
('Toronto Pearson International Airport', 2, 2),
('Heathrow Airport', 3, 3),
('Berlin Brandenburg Airport', 4, 4),
('Charles de Gaulle Airport', 5, 5);

INSERT INTO plane_model (description, graphic) VALUES
('Boeing 737', 'graphic1.png'),
('Airbus A320', 'graphic2.png'),
('Boeing 787', 'graphic3.png'),
('Airbus A380', 'graphic4.png'),
('Boeing 747', 'graphic5.png');

INSERT INTO flight_number (departure_time, description, type, airline, id_airport_start, id_airport_goal, id_plane_model) VALUES
('08:00:00', 'Morning Flight', 'Domestic', 'Delta', 1, 2, 1),
('12:00:00', 'Afternoon Flight', 'International', 'Air Canada', 2, 3, 2),
('16:00:00', 'Evening Flight', 'Domestic', 'British Airways', 3, 4, 3),
('20:00:00', 'Night Flight', 'International', 'Lufthansa', 4, 5, 4),
('23:00:00', 'Late Night Flight', 'Domestic', 'Air France', 5, 1, 5);

INSERT INTO flight_category (name) VALUES
('Economy'),
('Business'),
('First Class'),
('Premium Economy'),
('Economy Plus');

INSERT INTO flight (boarding_time, flight_date, gate, check_in_counter, id_flight_number, id_flight_category) VALUES
('07:30:00', '2024-08-01', 'A1', '1', 1, 1),
('11:30:00', '2024-08-02', 'B2', '2', 2, 2),
('16:00:00', '2024-08-03', 'C3', '3', 3, 3),
('20:00:00', '2024-08-04', 'D4', '4', 4, 4),
('23:00:00', '2024-08-05', 'E5', '5', 5, 5);

INSERT INTO coupon (id_ticket, date_of_redemption, class, stand_by, meal_code, id_flight) VALUES
(1, '2024-08-01', 'Economy', 'No', 'VEG', 1),
(2, '2024-08-02', 'Business', 'Yes', 'NON', 2),
(3, '2024-08-03', 'First Class', 'No', 'HAL', 3),
(4, '2024-08-04', 'Premium Economy', 'No', 'VGN', 4),
(5, '2024-08-05', 'Economy Plus', 'Yes', 'KOS', 5);

INSERT INTO pieces_of_luggage (number, weight, id_coupon) VALUES
(1, 23.5, 1),
(2, 15.0, 2),
(3, 20.0, 3),
(4, 18.7, 4),
(5, 22.3, 5);

INSERT INTO seat (size, number, location, id_plane_model) VALUES
(30.0, 1, 'Window', 1),
(30.0, 2, 'Aisle', 1),
(40.0, 3, 'Middle', 2),
(40.0, 4, 'Window', 2),
(50.0, 5, 'Aisle', 3);

INSERT INTO available_seat (id_coupon, id_flight, id_seat) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5);

INSERT INTO airplane (registration_number, begin_of_operation, status, id_plane_model) VALUES
('N123AB', '2024-01-01', 'Operational', 1),
('C456DE', '2024-02-15', 'Operational', 2),
('G789HI', '2024-03-30', 'Maintenance', 3),
('J012KL', '2024-04-10', 'Operational', 4),
('M345NO', '2024-05-20', 'Operational', 5);

--select * from airplane;