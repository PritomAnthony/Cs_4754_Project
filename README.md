# Cs_4754_Project
Project for comp 4754
## To load the dummy data, few adujustments are needed in mySQL workbench: 
    - MySQL Workbench, go to "Edit" → "Preferences" → "SQL Editor" → "DBMS connection read time out" and increase the value to 60.

 - Step to Prevent Concurrent Bookings in the "AddBooking" stored procedure
    - We have set the isolation level to SERIALIZABLE for the transaction. This ensures that a transaction has exclusive access to the rows it reads until the transaction completes.


# Steps to get this to work:

1. Navigate into the "hotel-management-system" folder.
2. Run "npm install" in command line.
3. ~~Go into the server.js file and input your SQL username and password into the "user" and "password" fields (and save the file).~~ Should not need to do this anymore as I have created an "admin" user. Should be able to connect directly with the "admin" username and "abcd1234" password (I have already added that into the code).
4. Run "node .\server.js" in command line.
5. Go to "http://localhost:3000/" in browser.
