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
    bookingNumber INT AUTO_INCREMENT PRIMARY KEY,
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
    orderDate DATE NOT NULL,
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

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\address_final.csv'
INTO TABLE Address
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(addressID, postalCode, city, province, street);  -- Skip the header row


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\customers.csv'
INTO TABLE Customer
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;  -- Skip the header row

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\hotels.csv'
INTO TABLE Hotel
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(hotelNumber, hotelName, addressID);  -- Skip the header row

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
(customerID, hotelNumber, roomNumber, paymentType, checkInDate, checkOutDate, @checkedOut, roomCost)
SET checkedOut = CASE
    WHEN @checkedOut = 'True' THEN 1
    WHEN @checkedOut = 'False' THEN 0
    ELSE NULL
END;


-- EMPLOYEE GOES HERE
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\employees.csv'
INTO TABLE Employee
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(employeeID, hotelNumber, firstName, lastName, department);  -- Skip the header row

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\food_orders.csv'
INTO TABLE FoodOrder
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(orderId, bookingNumber, price, orderDate);



 - ###########  Indexes and testing query ##############

CREATE INDEX idx_city_province ON Address(city, province);
CREATE INDEX idx_postal_code ON Address(postalCode);

/* 
SELECT addressID, postalCode, street
FROM Address
WHERE city = 'South Barbara' AND province = 'Prince Edward Island';
*/

/* 
SELECT addressID, city, province, street
FROM Address
WHERE postalCode = 'P1S 7Y4';
*/

CREATE INDEX idx_name ON Customer(firstName, lastName);
/* 
SELECT * 
FROM Customer 
WHERE firstName = 'Stacey' AND lastName = 'Nelson';
*/

CREATE INDEX idx_customer_hotel_room_checkIn ON Booking(hotelNumber, roomNumber, checkInDate);
/* 
SELECT bookingNumber, customerID, checkOutDate, roomCost
FROM Booking
WHERE hotelNumber = 17
  AND roomNumber = 1644
  AND checkInDate >= '2024-05-06'
ORDER BY checkInDate;
*/

/*
SELECT bookingNumber,roomNumber, HotelNumber, checkInDate, checkOutDate, roomCost
FROM Booking
WHERE customerID = 781728
ORDER BY checkInDate;
 */
 
 CREATE INDEX idx_name ON Employee(firstName, lastName);
 CREATE INDEX idx_name ON FoodOrder(orderDate);
 
 
 -- ################  Triggers  ##################
 
-- Trigger to check before booking is a room is available
DELIMITER $$
CREATE TRIGGER before_booking_insert
BEFORE INSERT ON Booking
FOR EACH ROW
BEGIN
    DECLARE room_status INT;
    SELECT available INTO room_status
    FROM HotelRoom
    WHERE roomNumber = NEW.roomNumber AND hotelNumber = NEW.hotelNumber;

    -- If the room is not available, throw an error
    IF room_status = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Room is not available for booking.';
    END IF;
END$$
DELIMITER ;

 -- Triger to update room availibity
 DELIMITER $$
CREATE TRIGGER update_room_availability_after_checkout
AFTER UPDATE ON booking
FOR EACH ROW
BEGIN
    -- Check if the 'checkedOut' column has changed from 0 to 1
    IF OLD.checkedOut = 0 AND NEW.checkedOut = 1 THEN
        UPDATE hotelroom
        SET available = 1  
        WHERE hotelNumber = NEW.hotelNumber
          AND roomNumber = NEW.roomNumber;
    END IF;
END $$
DELIMITER ;


-- ################ Transaction #################
-- stored procedure using transaction to add new booking

DELIMITER $$
CREATE PROCEDURE AddBooking(
    IN p_customerID INT,
    IN p_hotelNumber INT,
    IN p_roomNumber INT,
    IN p_paymentType VARCHAR(20),
    IN p_checkInDate DATE,
    IN p_checkOutDate DATE,
    IN p_checkedOut BOOLEAN,
    IN p_roomCost DECIMAL(10, 2)
)
BEGIN
    -- Declare variables for error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback transaction if any error occurs
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Transaction failed. Changes rolled back.';
    END;

    -- Start transaction
    START TRANSACTION;

    -- Insert a new booking without specifying bookingNumber (AUTO_INCREMENT will handle it)
    INSERT INTO Booking (
        customerID, hotelNumber, roomNumber, paymentType, 
        checkInDate, checkOutDate, checkedOut, roomCost
    )
    VALUES (
        p_customerID, p_hotelNumber, p_roomNumber, p_paymentType, 
        p_checkInDate, p_checkOutDate, p_checkedOut, p_roomCost
    );

    -- Update the room availability to 0 (booked)
    UPDATE HotelRoom
    SET available = 0
    WHERE hotelNumber = p_hotelNumber AND roomNumber = p_roomNumber;

    -- Commit the transaction
    COMMIT;

    -- Optionally, return the new bookingNumber (auto-generated)
    SELECT LAST_INSERT_ID() AS bookingNumber;

END$$

DELIMITER ;


CALL AddBooking(
    1,           
    17,           
    1640,         
    'Credit Card', 
    '2024-05-10', 
    '2024-05-15',  
    0,             
    500.00        
);

