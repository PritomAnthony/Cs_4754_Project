const express = require('express');
const mysql = require('mysql2');
const app = express();
const port = 3000;
const path = require('path');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'abcd1234',
  database: 'hotelmanagement'
});

connection.connect((err) => {
  if (err) {
    console.error('Error connecting to the database: ' + err.stack);
    return;
  }
  console.log('Connected to the database with ID ' + connection.threadId);
});

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.get('/hotels', (req, res) => {
  connection.query('SELECT * FROM hotel', (err, results) => {
    if (err) {
      res.status(500).send('Error fetching hotels');
      return;
    }
    res.json(results);
  });
});

app.get('/topHotels', (req, res) => {
  connection.query('SELECT h.hotelName, count(b.hotelNumber) AS numberOfBookings\
                    FROM hotel h\
                    JOIN booking b ON h.hotelNumber = b.hotelNumber\
                    GROUP BY h.hotelNumber\
                    ORDER BY numberOfBookings DESC\
                    LIMIT 5', (err, results) => {
    if (err) {
      res.status(500).send('Error fetching top hotels');
      return;
    }
    res.json(results);
  });
});


app.get('/availableRooms', (req, res) => {
  const { hotelNumber, roomCategory } = req.query;

  if (!hotelNumber || !roomCategory) {
    return res.status(400).send('Please provide Hotel Number and Room Category.');
  }

  connection.query('CALL get_available_rooms(?, ?)', [hotelNumber, roomCategory], (err, results) => {
    if (err) {
      console.error('Error fetching available rooms:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    res.json(results[0])
  });
});

// Try this in  route with this =  First name  = Michael , last name =  Alexander  postal code = L4A4L8
app.get('/checkCustomer', (req, res) => {
  const { firstName, lastName, postalCode } = req.query;

  const trimmedFirstName = firstName.trim();
  const trimmedLastName = lastName.trim();
  const trimmedPostalCode = postalCode.trim();
  
  if (!trimmedFirstName || !trimmedLastName || !trimmedPostalCode) {
    return res.status(400).send('Please provide firstName, lastName, and postalCode.');
  }

  // Find the addressID
  connection.query(
    'SELECT addressID FROM Address WHERE postalCode = ?',
    [trimmedPostalCode],
    (err, addressResults) => {
      if (err) {
        console.error('Error fetching address:', err);
        return res.status(500).send('Error fetching address data.');
      }

      if (addressResults.length === 0) {
        return res.status(404).send('No address found for the provided postal code.');
      }

      const addressID = addressResults[0].addressID;                                    // we get the addressID for the given postal code from "Address" table
      // Check if the customer exists
      connection.query(
        'SELECT customerID FROM Customer WHERE firstName = ? AND lastName = ? AND addressID = ?',
        [trimmedFirstName, trimmedLastName, addressID],
        (err, customerResults) => {
          if (err) {
            console.error('Error fetching customer:', err);
            return res.status(500).send('Error fetching customer data.');
          }

          if (customerResults.length > 0) {                                                 // Customer exists
            return res.json({ 
              customerID: customerResults[0].customerID,
              message: `The customer already existed, their customerID is : ${customerResults[0].customerID}` 
            });
          } 
          else {                                                                          // Customer does not exist, add that customer
            connection.query(
              'SELECT MAX(customerID) AS maxCustomerID FROM Customer',
              (err, maxIDResult) => {
                if (err) {
                  console.error('Error fetching maximum customerID:', err);
                  return res.status(500).send('Error fetching customerID.');
                }

                const newCustomerID = (maxIDResult[0].maxCustomerID || 0) + 1;               // need new customer ID so we increment the last customerID to get new one
                const loyaltyPts = 0;                                                        // new  customer's loyalty points will be 0

                // Insert new customer
                connection.query(
                  'INSERT INTO Customer (customerID, firstName, lastName, addressID, loyaltyPts) VALUES (?, ?, ?, ?, ?)',
                  [newCustomerID, trimmedFirstName, trimmedLastName, addressID, loyaltyPts],
                  (err, insertResult) => {
                    if (err) {
                      console.error('Error adding new customer:', err);
                      return res.status(500).send('Error adding new customer.');
                    }

    
                    res.json({                                                       // upon successful registration
                      customerID: newCustomerID,
                      message: `The customer is new, so added with customerID: ${newCustomerID}`
                    });
                  });
              });
          }
        });
    });
});

app.post('/createBooking', (req, res) => {
  const { customerID, hotelNumber, roomNumber, paymentType, checkInDate, checkOutDate, checkedOut } = req.body;

  if (!customerID || !hotelNumber || !roomNumber || !checkInDate || !checkOutDate || !paymentType) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
  }

  
  // Prepare the stored procedure call
  // const results = "CALL AddBooking(665, 5, 408, 'Credit Card', '2024-11-25', '2024-11-30', 0)";

  connection.query(
    "CALL AddBooking(?, ?, ?, ?, ?, ?, ?)",
    [customerID, hotelNumber, roomNumber, paymentType, checkInDate, checkOutDate, checkedOut],
    (err, results) => {
      if (err) {
        console.error('Error calling stored procedure:', err);
        return res.status(500).json({ error: 'Database error' });
      }

      const bookingNumber = results[1][0]?.bookingNumber;
      console.log('Booking Number:', bookingNumber);

      if (bookingNumber) {
        return res.json({ success: true, bookingNumber });
      } else {
        return res.status(500).json({ success: false, message: 'Failed to create booking' });
      }
    }
  );
});


app.delete('/deleteBooking/:bookingNumber', (req, res) => {
  const { bookingNumber } = req.params;

  connection.query('DELETE FROM Booking WHERE bookingNumber = ?', [bookingNumber], (err, results) => {
      if (err) {
          console.error('Error deleting booking:', err);
          return res.status(500).json({ error: 'Database error' });
      }

      if (results.affectedRows === 0) {
          return res.status(404).json({ success: false, message: 'Booking not found.' });
      }

      return res.json({ success: true, message: 'Booking deleted successfully.' });
  });
});

app.get('/viewBooking/:bookingNumber', (req, res) => {
  const { bookingNumber } = req.params;
  connection.query('SELECT * FROM booking WHERE bookingNumber = ?', [bookingNumber], (err, results) => {
    if (err) {
      res.status(500).send('Error fetching booking');
      return;
    }
    res.json(results[0]);
  });
});

app.post('/addFoodOrder', (req, res) => {
  const { bookingNumber, price } = req.body;

  if (!bookingNumber || !price) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
  }

  connection.query(
    "CALL add_food_order(?, ?)",
    [bookingNumber, price],
    (err, results) => {
      if (err) {
        console.error('Error calling stored procedure:', err);
        return res.status(500).json({ error: 'Database error' });
      }
      const orderID = results[0][0].orderID;
      console.log('Order ID:', orderID);

      if (orderID) {
        return res.json({ success: true, orderID });
      } else {
        return res.status(500).json({ success: false, message: 'Failed to create food order' });
      }
    }
  );
});

app.get('/viewFoodOrder/:orderID', (req, res) => {
  const { orderID } = req.params;
  connection.query('SELECT * FROM foodorder WHERE orderID = ?', [orderID], (err, results) => {
    if (err) {
      res.status(500).send('Error fetching food order');
      return;
    }
    res.json(results[0]);
  });
});

app.delete('/deleteFoodOrder/:orderID', (req, res) => {
  const { orderID } = req.params;

  connection.query('DELETE FROM foodorder WHERE orderID = ?', [orderID], (err, results) => {
      if (err) {
          console.error('Error deleting food order:', err);
          return res.status(500).json({ error: 'Database error' });
      }

      if (results.affectedRows === 0) {
          return res.status(404).json({ success: false, message: 'Food order not found.' });
      }

      return res.json({ success: true, message: 'Food order deleted successfully.' });
  });
});


const getNextEmployeeId = async () => {
  return new Promise((resolve, reject) => {
      db.query('SELECT MAX(employeeId) AS maxId FROM Employee', (err, results) => {
          if (err) return reject(err);
          const nextId = (results[0].maxId || 0) + 1;
          resolve(nextId);
      });
  });
};

// Add Employee
app.post('/add-employee', async (req, res) => {
  const { hotelNumber, firstName, lastName, department } = req.body;

  if (!hotelNumber || !firstName || !lastName || !department) {
      return res.status(400).send({ message: 'All fields are required.' });
  }

  try {
      const nextEmployeeId = await getNextEmployeeId();

      const query = 'INSERT INTO Employee (employeeId, hotelNumber, firstName, lastName, department) VALUES (?, ?, ?, ?, ?)';
      db.query(query, [nextEmployeeId, hotelNumber, firstName, lastName, department], (err, result) => {
          if (err) {
              console.error(err);
              return res.status(500).send({ message: 'Error adding employee.' });
          }
          res.status(200).send({ message: 'Employee added successfully!', employeeId: nextEmployeeId });
      });
  } catch (error) {
      res.status(500).send({ message: 'Error fetching next employee ID.', error });
  }
});

// Delete Employee
app.delete('/delete-employee/:employeeId', (req, res) => {
  const { employeeId } = req.params;

  const checkQuery = 'SELECT * FROM Employee WHERE employeeId = ?';
  db.query(checkQuery, [employeeId], (err, results) => {
      if (err) {
          console.error(err);
          return res.status(500).send({ message: 'Error checking employee existence.' });
      }

      if (results.length === 0) {
          return res.status(404).send({ message: 'Employee not found.' });
      }

      const deleteQuery = 'DELETE FROM Employee WHERE employeeId = ?';
      db.query(deleteQuery, [employeeId], (err, result) => {
          if (err) {
              console.error(err);
              return res.status(500).send({ message: 'Error deleting employee.' });
          }
          res.status(200).send({ message: 'Employee deleted successfully!' });
      });
  });
});

// Update Employee
app.put('/update-employee', (req, res) => {
  const { employeeId, hotelNumber, firstName, lastName, department } = req.body;

  if (!employeeId || !hotelNumber || !firstName || !lastName || !department) {
      return res.status(400).send({ message: 'All fields are required for updating.' });
  }

  const checkQuery = 'SELECT * FROM Employee WHERE employeeId = ?';
  db.query(checkQuery, [employeeId], (err, results) => {
      if (err) {
          console.error(err);
          return res.status(500).send({ message: 'Error checking employee existence.' });
      }

      if (results.length === 0) {
          return res.status(404).send({ message: 'Employee not found.' });
      }

      const updateQuery = `
          UPDATE Employee 
          SET hotelNumber = ?, firstName = ?, lastName = ?, department = ? 
          WHERE employeeId = ?`;
      db.query(updateQuery, [hotelNumber, firstName, lastName, department, employeeId], (err, result) => {
          if (err) {
              console.error(err);
              return res.status(500).send({ message: 'Error updating employee.' });
          }
          res.status(200).send({ message: 'Employee updated successfully!' });
      });
  });
});



app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
