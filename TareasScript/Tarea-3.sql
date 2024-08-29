/*Nombre: Jose Carlos Giron Solano
  Registro: 216161924
*/
IF EXISTS(SELECT name FROM master.sys.databases WHERE name=N'SoporteBD')
BEGIN
	PRINT 'La base de datos ya existe';
	DROP DATABASE SoporteBD;
END
GO

CREATE DATABASE SoporteBD;
GO
USE SoporteBD;
GO

IF OBJECT_ID('customer','U') IS NOT NULL
DROP TABLE customer;
GO

CREATE TABLE customer(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	date_of_birth DATE NOT NULL,
	"name" VARCHAR(255),
	CONSTRAINT CHK_customer_date_of_birth CHECK (date_of_birth < GETDATE())
);
GO
CREATE INDEX IDX_customer_name ON customer("name");
GO
CREATE TABLE customer_category(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[name] VARCHAR(50) NOT NULL,
	id_customer INT NOT NULL,
	FOREIGN KEY (id_customer) REFERENCES customer(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT UQ_customer_category_name UNIQUE([name])
)
GO
CREATE INDEX IDX_customer_category ON customer_category([name]);
GO

CREATE TABLE frequent_flyer_card (
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	ffc_number INT NOT NULL,
	miles INT,
	meal_code VARCHAR(10),
	id_customer INT NOT NULL,
	FOREIGN KEY(id_customer) REFERENCES customer(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT UQ_frequent_flyer_card_ffc_number UNIQUE(ffc_number),
	CONSTRAINT CHK_miles CHECK (miles>0)
);
GO
CREATE INDEX IDX_frequent_flyer_card_ffc_number ON frequent_flyer_card(ffc_number);
GO

CREATE TABLE ticket(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	ticketing_code INT NOT NULL,
	number INT NOT NULL,
	id_customer INT NOT NULL,
	FOREIGN KEY (id_customer) REFERENCES customer(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT UQ_ticket_ticketing_code_number UNIQUE (ticketing_code, number)
);
GO

CREATE TABLE country(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	"name" VARCHAR(100),
	CONSTRAINT UQ_country_name UNIQUE("name")
);
GO

CREATE TABLE identification_document(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	document_number VARCHAR(50) NOT NULL,
	issue_date DATE NOT NULL,
	expiration_date DATE NOT NULL,
	issue_country INT NOT NULL,
	id_customer INT NOT NULL,
	FOREIGN KEY (issue_country) REFERENCES country(id),
	FOREIGN KEY (id_customer) REFERENCES customer(id),
	CONSTRAINT UQ_identification_document_document_number UNIQUE(document_number),
	CONSTRAINT CHK_identification_document_issue_date CHECK(issue_date<=GETDATE()),
	CONSTRAINT CHK_identification_document_expiration_date CHECK(expiration_date>GETDATE()),
	CONSTRAINT CHK_identification_document_issue_country CHECK(issue_country>0)
)
GO
CREATE INDEX IDX_identification_document_document_number ON identification_document(document_number);
GO

CREATE TABLE city(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	"name" VARCHAR(100) UNIQUE,
	id_country INT NOT NULL,
	FOREIGN KEY (id_country) REFERENCES country(id)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	CONSTRAINT CHK_city_id_country CHECK(id_country>0)
)
GO

CREATE TABLE airport(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	"name" VARCHAR(255) NOT NULL,
	id_city INT NOT NULL,
	FOREIGN KEY (id_city) REFERENCES city(id),
	CONSTRAINT CHK_airport_id_city CHECK(id_city>0)
)
GO
CREATE INDEX IDX_airport_name ON airport("name");
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
	ON UPDATE CASCADE,
	CONSTRAINT CHK_fligth_number_id_airport_start CHECK(id_airport_start>0),
	CONSTRAINT CHK_fligth_number_id_airport_goal CHECK(id_airport_goal>0),
	CONSTRAINT CHK_fligth_number_id_airport_plane_model CHECK(id_plane_model>0),
)
GO

CREATE TABLE flight(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	boarding_time TIME NOT NULL,
	flight_date DATE NOT NULL,
	gate VARCHAR(10) NOT NULL,
	check_in_counter VARCHAR(10) NOT NULL,
	id_flight_number INT NOT NULL,
	FOREIGN KEY(id_flight_number) REFERENCES flight_number(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT CHK_flight_flight_date CHECK(flight_date>GETDATE())
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
	ON UPDATE CASCADE,
	CONSTRAINT CHK_coupon_date_of_redemption CHECK (date_of_redemption <= GETDATE()),
)

GO
CREATE TABLE pieces_of_luggage(
	id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	number INT NOT NULL,
	"weight" DECIMAL NOT NULL, 
	id_coupon INT NOT NULL,
	FOREIGN KEY (id_coupon) REFERENCES coupon(id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT CHK_pieces_of_luggage_weight CHECK ("weight" > 0),
    CONSTRAINT CHK_pieces_of_luggage_number CHECK (number > 0)
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
	ON UPDATE CASCADE,
	CONSTRAINT CHK_seat_size CHECK (size > 0),
    CONSTRAINT CHK_seat_number CHECK (number > 0)
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
	ON UPDATE CASCADE,
	CONSTRAINT UQ_airplane_registration_number UNIQUE(registration_number),
	CONSTRAINT CHK_airplane_begin_of_operation CHECK(begin_of_operation<=GETDATE())
)
GO


INSERT INTO customer (date_of_birth, "name") VALUES
('1985-06-15', 'John Doe'),
('1990-09-22', 'Jane Smith'),
('1978-11-30', 'Alice Johnson'),
('2001-04-12', 'Bob Brown');

INSERT INTO customer_category ([name], id_customer) VALUES
('Regular', 1),
('VIP', 2),
('Frequent', 3),
('Occasional', 4);

INSERT INTO frequent_flyer_card (ffc_number, miles, meal_code, id_customer) VALUES
(1001, 15000, 'VGML', 1),
(1002, 20000, 'KSML', 2),
(1003, 5000, NULL, 3),
(1004, 12000, 'GFML', 4);

INSERT INTO ticket (ticketing_code, number, id_customer) VALUES
(111, 1, 1),
(112, 2, 2),
(113, 3, 3),
(114, 4, 4);

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

INSERT INTO identification_document (document_number, issue_date, expiration_date, issue_country, id_customer) VALUES
('A1234567', '2010-01-01', '2020-12-31', 1, 1),
('B2345678', '2012-05-15', '2022-05-14', 2, 2),
('C3456789', '2015-09-01', '2025-08-31', 3, 3),
('D4567890', '2018-11-20', '2028-11-19', 4, 4);

INSERT INTO airport (name, id_city) VALUES
('JFK International Airport', 1),
('Toronto Pearson International Airport', 2),
('Heathrow Airport', 3),
('Berlin Brandenburg Airport', 4);

INSERT INTO plane_model (description, graphic) VALUES
('Boeing 737', 'graphic1.png'),
('Airbus A320', 'graphic2.png'),
('Boeing 787', 'graphic3.png'),
('Airbus A380', 'graphic4.png'),
('Boeing 747', 'graphic5.png');

INSERT INTO flight_number (departure_time, "description", "type", airline, id_airport_start, id_airport_goal, id_plane_model) VALUES
('10:00:00', 'Morning Flight to London', 'International', 'British Airways', 1, 4, 4),
('12:30:00', 'Afternoon Flight to Toronto', 'International', 'Air Canada', 1, 2, 2),
('15:45:00', 'Evening Flight to Mexico City', 'International', 'Aeroméxico', 1, 3, 1),
('08:00:00', 'Early Flight to New York', 'Domestic', 'American Airlines', 4, 1, 1);

INSERT INTO flight (boarding_time, flight_date, gate, check_in_counter, id_flight_number) VALUES
('10:00:00', '2024-09-15', 'A1', '1', 1),
('12:30:00', '2024-09-16', 'B2', '2', 2),
('15:45:00', '2024-09-17', 'C3', '3', 3),
('08:00:00', '2024-09-18', 'D4', '4', 4);

INSERT INTO coupon (id_ticket, date_of_redemption, class, stand_by, meal_code, id_flight) VALUES
(1, '2024-08-15', 'Economy', NULL, 'VGML', 1),
(2, '2024-08-16', 'Business', 'Yes', 'KSML', 2),
(3, '2024-08-17', 'First', NULL, 'GFML', 3),
(4, '2024-08-18', 'Economy', 'No', NULL, 4);

INSERT INTO pieces_of_luggage (number, weight, id_coupon) VALUES
(1, 23.50, 1),
(2, 18.75, 2),
(3, 20.00, 3),
(4, 15.00, 4);

INSERT INTO flight (boarding_time, flight_date, gate, check_in_counter, id_flight_number) VALUES
('07:30:00', '2024-08-01', 'A1', '1', 1),
('11:30:00', '2024-08-02', 'B2', '2',2 ),
('16:00:00', '2024-08-03', 'C3', '3', 3),
('20:00:00', '2024-08-04', 'D4', '4', 4),
('23:00:00', '2024-08-05', 'E5', '5', 5);

INSERT INTO seat (size, number, "location", id_plane_model) VALUES
(2.00, 1, 'Window', 1),
(2.00, 2, 'Aisle', 1),
(2.50, 3, 'Window', 2),
(2.50, 4, 'Middle', 2);


INSERT INTO available_seat (id_coupon, id_flight, id_seat) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4);

INSERT INTO airplane (registration_number, begin_of_operation, "status", id_plane_model) VALUES
('N12345', '2010-01-01', 'Active', 1),
('C67890', '2015-05-15', 'Active', 2),
('G54321', '2020-10-10', 'Maintenance', 3),
('B09876', '2018-03-25', 'Retired', 4);

--select * from airplane;