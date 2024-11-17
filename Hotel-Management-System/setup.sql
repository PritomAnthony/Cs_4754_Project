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
    roomNumber INT,
    hotelNumber INT,
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
    FOREIGN KEY(hotelNumber, roomNumber) REFERENCES HotelRoom(hotelNumber, roomNumber)
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
SHOW VARIABLES LIKE 'secure_file_priv';
-- It will show you a folder name like this -> C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
-- You need to add the csv files to this folder and use this folder address in the code below (in the LOAD DATA INFILE part)
-- Make sure to add an extra backslash in front of the one there because you need to escape them or something
-- NOT C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
-- NEED THIS C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\updated_address.csv'
INTO TABLE Address
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(addressID, postalCode, city, province, street);  -- Skip the header row


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\updated_customers.csv'
INTO TABLE Customer
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;  -- Skip the header row

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\updated_hotels.csv'
INTO TABLE Hotel
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;  -- Skip the header row

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\roomcategories.csv'
INTO TABLE RoomCategory
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;  -- Skip the header row

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\hotel_rooms.csv'
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

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\bookings.csv'
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

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\updated_employees.csv'
INTO TABLE Employee
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;  -- Skip the header row

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\food_orders.csv'
INTO TABLE FoodOrder
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;  -- Skip the header row

/*
CODE TO CREATE USERS (does not need to be executed again):

create role read_only_user;
grant select, show view, create view on hotelmanagement.* to read_only_user;
create user 'read' identified by 'abcd1234' default role read_only_user;

create role data_writer;
grant select, insert, update, delete on hotelmanagement.* to data_writer;
create user 'data' identified by 'abcd1234' default role data_writer;

create role admin_user;
grant all privileges on hotelmanagement.* to admin_user;
create user 'admin' identified by 'abcd1234' default role admin_user;
*/

