SHOW VARIABLES LIKE 'secure_file_priv';
-- It will show you a folder name similar to this -> C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
-- You need to add the csv files to this folder and use this folder address in the code at the bottom of this file (in the LOAD DATA INFILE part)
-- Make sure to add an extra backslash in front of the one there to escape it
-- NOT C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
-- NEED THIS C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\

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
    TelNumber VARCHAR(15) NOT NULL UNIQUE,
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
    orderID INT AUTO_INCREMENT PRIMARY KEY,
    bookingNumber INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    orderDate DATE NOT NULL,
    FOREIGN KEY(bookingNumber) REFERENCES Booking(bookingNumber) ON DELETE CASCADE
);








-- CODE TO CREATE USERS (does not need to be executed twice):
CREATE ROLE read_role;
GRANT SELECT, SHOW VIEW ON hotelmanagement.* TO read_role;
CREATE USER IF NOT EXISTS 'read_user' IDENTIFIED BY 'abcd1234' DEFAULT ROLE read_role;
CREATE ROLE write_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON hotelmanagement.* TO write_role;
CREATE USER 'write_user' IDENTIFIED BY 'abcd1234' DEFAULT ROLE write_role;
CREATE ROLE admin_user;
GRANT ALL ON hotelmanagement.* TO admin_user;
CREATE USER 'admin' IDENTIFIED BY 'abcd1234' DEFAULT ROLE admin_user;



 -- ###########  Indexes and testing query ##############

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

CREATE INDEX  idx_customer_firstName_lastName ON Customer(firstName, lastName);
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
 
 CREATE INDEX idx_employee_firstName_lastName ON Employee(firstName, lastName);
 CREATE INDEX idx_foodOrder_orderDate ON FoodOrder(orderDate);

 
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

DROP TRIGGER IF EXISTS calculate_room_cost;
DELIMITER //
CREATE TRIGGER calculate_room_cost
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
	DECLARE v_roomCategory VARCHAR(50);
    DECLARE v_roomPrice DECIMAL(10, 2);
    DECLARE v_daysBooked INT;

    -- Fetch the room category
    SELECT categoryNumber
    INTO v_roomCategory
    FROM HotelRoom
    WHERE hotelNumber = NEW.hotelNumber AND roomNumber = NEW.roomNumber;
	
    SELECT price 
    INTO v_roomPrice
    FROM roomcategory
    WHERE categoryNumber = v_roomCategory;

	SET v_daysBooked = DATEDIFF(NEW.checkOutDate, NEW.checkInDate);
    
    SET NEW.roomCost = v_daysBooked * v_roomPrice;
END //
DELIMITER ;

-- ################ Transaction #################
-- stored procedure using transaction to add new booking
DROP PROCEDURE IF EXISTS AddBooking;

DELIMITER $$
CREATE PROCEDURE AddBooking(
    IN p_customerID INT,
    IN p_hotelNumber INT,
    IN p_roomNumber INT,
    IN p_paymentType VARCHAR(20),
    IN p_checkInDate DATE,
    IN p_checkOutDate DATE,
    IN p_checkedOut BOOLEAN
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

    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    START TRANSACTION;

    SELECT available 
    FROM HotelRoom
    WHERE hotelNumber = p_hotelNumber AND roomNumber = p_roomNumber
    FOR UPDATE;

    -- check if the room is available
    IF (SELECT available 
        FROM HotelRoom 
        WHERE hotelNumber = p_hotelNumber AND roomNumber = p_roomNumber) = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Room is not available for booking.';
    ELSE
        -- Insert a new booking
        INSERT INTO Booking (
            customerID, hotelNumber, roomNumber, paymentType, 
            checkInDate, checkOutDate, checkedOut
        )
        VALUES (
            p_customerID, p_hotelNumber, p_roomNumber, p_paymentType, 
            p_checkInDate, p_checkOutDate, p_checkedOut
        );

        -- Update the room availability to 0 (booked)
        UPDATE HotelRoom
        SET available = 0
        WHERE hotelNumber = p_hotelNumber AND roomNumber = p_roomNumber;
    END IF;

    COMMIT;

    -- Optionally, return the new bookingNumber (auto-generated)
    SELECT LAST_INSERT_ID() AS bookingNumber;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS DeleteBooking;
DELIMITER $$
CREATE PROCEDURE DeleteBooking(
    IN p_bookingNumber INT
)
BEGIN
	DECLARE v_hotelNumber INT;
    DECLARE v_roomNumber INT;

	SELECT hotelNumber, roomNumber
    INTO v_hotelNumber, v_roomNumber
    FROM Booking
    WHERE bookingNumber = p_bookingNumber;
    
    UPDATE HotelRoom
    SET available = 1
    WHERE hotelNumber = v_hotelNumber AND roomNumber = v_roomNumber
      AND EXISTS (
        SELECT 1
        FROM Booking b
        WHERE b.hotelNumber = v_hotelNumber
          AND b.roomNumber = v_roomNumber
          AND b.checkInDate = (
              SELECT MAX(checkInDate)
              FROM Booking
              WHERE hotelNumber = v_hotelNumber AND roomNumber = v_roomNumber
          )
          AND b.checkOutDate = (
              SELECT MAX(checkOutDate)
              FROM Booking
              WHERE hotelNumber = v_hotelNumber AND roomNumber = v_roomNumber
          )
      );

	DELETE FROM Booking
    WHERE bookingNumber = p_bookingNumber;
    
    SELECT ROW_COUNT() AS affectedRows;

END$$
DELIMITER ;



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
DROP FUNCTION IF EXISTS get_available_room_count;
DROP PROCEDURE IF EXISTS get_available_rooms;

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


DELIMITER //
-- FUNCTION THAT RETURNS THE NUMBER OF AVAILABLE ROOMS GIVEN THE HOTEL NUMBER AND CATEGORY NAME (i.e. 'Single room')
CREATE FUNCTION get_available_room_count(hotel_number INT, category_name CHAR(100))
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


DELIMITER //
CREATE PROCEDURE get_available_rooms(hotel_number INT, category_name CHAR(100))
BEGIN
    DECLARE category_num INT;

    SELECT categoryNumber INTO category_num
    FROM RoomCategory
    WHERE category = category_name;

    SELECT roomNumber
    FROM HotelRoom H
    WHERE H.hotelNumber = hotel_number
      AND H.available IS TRUE
      AND H.categoryNumber = category_num;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS add_food_order;
DELIMITER //
CREATE PROCEDURE add_food_order(p_bookingNumber INT, p_price DECIMAL(10,2))
BEGIN
	DECLARE v_orderDate DATE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback transaction if any error occurs
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Transaction failed. Changes rolled back.';
    END;
    
    SET v_orderDate = CURRENT_DATE();
    
    INSERT INTO foodorder (bookingNumber, price, orderDate)
        VALUES (p_bookingNumber, p_price, v_orderDate);
        
	SELECT LAST_INSERT_ID() AS orderID;
END //

DELIMITER ;



-- READING CSV DATA
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\address.csv'
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
IGNORE 1 LINES
(customerID, firstName, lastName, addressID, loyaltyPts, TelNumber);  -- Skip the header row

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\hotels.csv'
INTO TABLE Hotel
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(hotelNumber, hotelName, addressID);  -- Skip the header row

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\room_categories.csv'
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
(customerID, hotelNumber, roomNumber, paymentType, checkInDate, checkOutDate, @checkedOut, @roomCost)
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
IGNORE 1 LINES;  -- Skip the header row

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\food_orders.csv'
INTO TABLE FoodOrder
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(bookingNumber, price, orderDate);