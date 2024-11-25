# Cs_4754_Project
Project for comp 4754


 - Step to Prevent Concurrent Bookings in the "AddBooking" stored procedure
    - We have set the isolation level to SERIALIZABLE for the transaction. This ensures that a transaction has exclusive access to the rows it reads until the transaction completes.
