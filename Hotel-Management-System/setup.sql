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
    postalCode CHAR(6) PRIMARY KEY,
    city VARCHAR(20) NOT NULL,
    province VARCHAR(20) NOT NULL,
    street VARCHAR(20) NOT NULL
);

CREATE Table Customer (
    customerID INT PRIMARY KEY,
    firstName CHAR(20) NOT NULL,
    lastName CHAR(20) NOT NULL,
    postalCode CHAR(6) NOT NULL,
    loyaltyPts INT,
    FOREIGN KEY(postalCode) REFERENCES Address(postalCode)
);

CREATE Table Hotel (
    hotelNumber INT PRIMARY KEY,
    hotelName VARCHAR(100) NOT NULL,
    postalCode CHAR(6) NOT NULL,
    FOREIGN KEY(postalCode) REFERENCES Address(postalCode)
);

CREATE Table RoomCategory (
    categoryNumber INT PRIMARY KEY,
    category CHAR(100) NOT NULL,
    price decimal(10, 2) NOT NULL
);

CREATE Table HotelRoom (
    roomNumber INT,
    hotelNumber INT,
    available BOOLEAN NOT NULL,
    categoryNumber INT NOT NULL,
    PRIMARY KEY(roomNumber, hotelNumber),
    FOREIGN KEY(hotelNumber) REFERENCES Hotel(hotelNumber)
);

CREATE Table Booking (
    bookingNumber INT PRIMARY KEY,
    customerID INT NOT NULL,
    roomNumber INT NOT NULL,
    paymentType VARCHAR(20),
    checkInDate DATE NOT NULL,
    checkOutDate DATE NOT NULL,
    checkedOut BOOLEAN,
    roomCost DECIMAL(10,2),
    FOREIGN KEY(customerID) REFERENCES Customer(customerID),
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
