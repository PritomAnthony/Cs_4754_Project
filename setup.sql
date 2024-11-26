CREATE DATABASE IF NOT EXISTS hotelManagement;
use hotelManagement;

DROP Table IF EXISTS FoodOrder;
DROP Table IF EXISTS Employee;
DROP Table IF EXISTS Booking;
DROP Table IF EXISTS HotelRoom;
DROP Table IF EXISTS RoomCategory;
DROP Table IF EXISTS Hotel;
DROP Table IF EXISTS Customer;
DROP Table IF EXISTS Address;

CREATE Table Address (
	addressID INT AUTO_INCREMENT PRIMARY KEY,
    postalCode CHAR(7),
    city VARCHAR(50) NOT NULL,
    province VARCHAR(50) NOT NULL,
    street VARCHAR(50) NOT NULL
);

CREATE Table Customer (
    customerID INT PRIMARY KEY,
    firstName CHAR(20) NOT NULL,
    lastName CHAR(20) NOT NULL,
    addressID INT NOT NULL,
    loyaltyPts INT,
    FOREIGN KEY (addressID) REFERENCES Address(addressID)
);

CREATE Table Hotel (
    hotelNumber INT PRIMARY KEY,
    hotelName VARCHAR(100) NOT NULL,
    addressID INT NOT NULL,
    FOREIGN KEY (addressID) REFERENCES Address(addressID)
);

CREATE Table RoomCategory (
    categoryNumber INT PRIMARY KEY,
    category CHAR(100) NOT NULL,
    price decimal(10, 2) NOT NULL
);

CREATE TABLE HotelRoom (
    roomNumber INT UNIQUE,
    hotelNumber INT UNIQUE,
    available BOOLEAN NOT NULL,
    categoryNumber INT NOT NULL,
    PRIMARY KEY (roomNumber, hotelNumber),
    FOREIGN KEY (hotelNumber) REFERENCES Hotel(hotelNumber),
    FOREIGN KEY (categoryNumber) REFERENCES RoomCategory(categoryNumber)
);

CREATE Table Booking (
    bookingNumber INT PRIMARY KEY,
    customerID INT NOT NULL,
    hotelNumber INT NOT NULL,
    roomNumber INT NOT NULL,
    paymentType VARCHAR(20),
    checkInDate DATE NOT NULL,
    checkOutDate DATE NOT NULL,
    checkedOut BOOLEAN,
    roomCost DECIMAL(10,2),
    FOREIGN KEY(customerID) REFERENCES Customer(customerID),
    FOREIGN KEY(hotelNumber) REFERENCES HotelRoom(hotelNumber),
    FOREIGN KEY(roomNumber) REFERENCES HotelRoom(roomNumber)
);

CREATE Table Employee (
    employeeID INT PRIMARY KEY,
    hotelNumber INT NOT NULL,
    firstName CHAR(20) NOT NULL,
    lastName CHAR(20) NOT NULL,
    department char(100),
    FOREIGN KEY(hotelNumber) REFERENCES Hotel(hotelNumber)
);

CREATE Table FoodOrder (
    orderID INT PRIMARY KEY,
    bookingNumber INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    orderDate DATETIME NOT NULL,
    FOREIGN KEY(bookingNumber) REFERENCES Booking(bookingNumber)
);

-- !!!!!!! IMPORTING CSV FILES INSTRUCTIONS !!!!!!!
-- Run this 
-- SHOW VARIABLES LIKE 'secure_file_priv';
-- It will show you a folder name like this -> C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
-- You need to add the csv files to this folder and use this folder address in the code below (in the LOAD DATA INFILE part)
-- Make sure to add an extra backslash in front of the one there because you need to escape them or something
-- NOT C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
-- NEED THIS C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\



LOAD DATA LOCAL INFILE '/Users/Soapy/Downloads/updated_address.csv'
INTO TABLE Address
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(addressID, postalCode, city, province, street);  -- Skip the header row


LOAD DATA LOCAL INFILE '/Users/Soapy/Downloads/updated_customers.csv'
INTO TABLE Customer
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;  -- Skip the header row

LOAD DATA LOCAL INFILE '/Users/Soapy/Downloads/updated_hotels.csv'
INTO TABLE Hotel
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;  -- Skip the header row

LOAD DATA LOCAL INFILE '/Users/Soapy/Documents/roomcategories.csv'
INTO TABLE RoomCategory
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;  -- Skip the header row

LOAD DATA LOCAL INFILE '/Users/Soapy/Documents/hotel_rooms.csv'
INTO TABLE HotelRoom
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(roomNumber, hotelNumber, @available, categoryNumber)
SET available = CASE
    WHEN @available = 'True' THEN 1
    WHEN @available = 'False' THEN 0
    ELSE NULL
END;  -- Skip the header row

LOAD DATA LOCAL INFILE '/Users/Soapy/Documents/bookings.csv'
INTO TABLE Booking
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(bookingNumber, customerID, hotelNumber, roomNumber, paymentType, checkInDate, checkOutDate, @checkedOut, roomCost)
SET checkedOut = CASE
    WHEN @checkedOut = 'True' THEN 1
    WHEN @checkedOut = 'False' THEN 0
    ELSE NULL
END;  -- Skip the header row

LOAD DATA LOCAL INFILE '/Users/Soapy/Downloads/updated_employees.csv'
INTO TABLE Employee
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;  -- Skip the header row

LOAD DATA LOCAL INFILE '/Users/Soapy/Downloads/food_orders.csv'
INTO TABLE FoodOrder
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;  -- Skip the header row


/*
-- CODE TO CREATE USERS (does not need to be executed again):

create role read_role;
grant select, show view on hotelmanagement.* to read_role;
create user 'read_user' identified by 'abcd1234' default role read_role;

create role write_role;
grant select, insert, update, delete on hotelmanagement.* to write_role;
create user 'write_user' identified by 'abcd1234' default role write_role;

create role admin_user;
grant all privileges on hotelmanagement.* to admin_user;
create user 'admin' identified by 'abcd1234' default role admin_user;*/


-- VIEW THAT SHOWS ALL BOOKINGS FOR A PARTICULAR DATE
CREATE OR REPLACE VIEW bookings_today (Hotel_Number, Booking_Number, Room_Number, Check_Out_Date) AS
SELECT hotelNumber AS Hotel_Number, bookingNumber AS Booking_Number, roomNumber AS Room_Number, checkOutDate As Check_Out_Date
FROM Booking
WHERE checkInDate = '2024-07-21'
ORDER BY hotelNumber;


-- VIEW THAT SHOWS ALL EMPLOYEES IN HOTEL NUMBER 1 WORKING IN HOUSEKEEPING (we can change the values to whatever)
SELECT * FROM bookings_today;

CREATE OR REPLACE VIEW get_employees (EmployeeID, First_Name, Last_Name, Hotel_Number, Department) AS
SELECT employeeID, firstName, lastName, hotelNumber, department
FROM Employee
WHERE hotelNumber = 1 AND REPLACE(department, CHAR(13), '') = 'Housekeeping'
ORDER BY employeeID;

SELECT * FROM get_employees;

DROP PROCEDURE IF EXISTS generateBill;

-- STORED PROCEDURE THAT GENERATES BILL GIVEN THE BOOKING NUMBER
-- roomCost (from Booking) + SUM(all food orders)
DELIMITER //
CREATE PROCEDURE generateBill (
	IN in_booking_number INT,
    OUT total_fees DECIMAL (10,2)
)
BEGIN
	DECLARE food_order_fees DECIMAL(10,2);
    DECLARE room_cost_fees DECIMAL(10,2);
    
    SELECT IFNULL(SUM(price), 0) INTO food_order_fees
    FROM FoodOrder
    WHERE bookingNumber = in_booking_number;
    
    SELECT IFNULL(roomCost, 0) INTO room_cost_fees
    FROM Booking
    WHERE bookingNumber = in_booking_number AND checkedOut = 1;
    
    SET total_fees = food_order_fees + room_cost_fees;
    
        SELECT 
        CONCAT('Booking Number: ', in_booking_number) AS Label, 
        '' AS COST
    UNION ALL
    SELECT 'Total room cost: ', room_cost_fees
    UNION ALL
    SELECT 'Total food order cost: ', food_order_fees
    UNION ALL
    SELECT 'Overall total cost: ', total_fees;
END //

SET @total_fees = 0;

CALL generateBill(325, @total_fees);

DROP FUNCTION IF EXISTS get_available_rooms;

-- FUNCTION THAT RETURNS THE NUMBER OF AVAILABLE ROOMS GIVEN THE HOTEL NUMBER AND CATEGORY NAME (i.e. 'Single room')
CREATE FUNCTION get_available_rooms(hotel_number INT, category_name CHAR(100))
RETURNS INT DETERMINISTIC
BEGIN
	
    DECLARE category_num INT;
	DECLARE room_count INT;
    DECLARE result_sentence VARCHAR(255);
    SELECT categoryNumber INTO category_num
    FROM RoomCategory
    WHERE category = category_name;

    SELECT COUNT(*) INTO room_count 
    FROM HotelRoom H
    WHERE H.hotelNumber = hotel_number AND H.available IS TRUE AND H.categoryNumber IN (
		SELECT C.categoryNumber
        FROM RoomCategory C
        WHERE C.categoryNumber = category_num);
        
	RETURN room_count;
    
END //

-- SELECT get_available_rooms(4, 'Single room');




