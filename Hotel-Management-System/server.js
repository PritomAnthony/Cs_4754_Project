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

// Try this in  route with this =  First name  = Michael , last name =  Alexander  postal code = L4A4L8
app.get('/checkCustomer', (req, res) => {
  const { firstName, lastName, postalCode } = req.query;

  const trimmedFirstName = firstName.trim();
  const trimmedLastName = lastName.trim();
  const trimmedPostalCode = postalCode.trim();

  if (!trimmedFirstName || !trimmedLastName || !trimmedPostalCode) {
    return res.status(400).send('Please provide firstName, lastName, and postalCode.');
  }

  // find the addressID
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

      const addressID = addressResults[0].addressID;
      connection.query(
        'SELECT customerID FROM customer WHERE firstName = ? AND lastName = ? AND addressID = ?',
        [trimmedFirstName, trimmedLastName, addressID],
        (err, customerResults) => {

          if (err) {
            console.error('Error fetching customer:', err);
            return res.status(500).send('Error fetching customer data.');
          }
          else if (customerResults.length > 0) {
            res.json({ customerID: customerResults[0].customerID });
          } 
          else {
            res.status(404).send('Customer not found.');
          }
        });
    });
});



app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
