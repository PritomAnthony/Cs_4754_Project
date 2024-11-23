document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('submit-booking').addEventListener('click', () => {
        const customerID = document.getElementById('customer-id').value.trim();
        const hotelNumber = document.getElementById('hotel-number-booking').value.trim();
        const roomNumber = document.getElementById('room-number').value.trim();
        const checkInDate = document.getElementById('check-in-date').value;
        const checkOutDate = document.getElementById('check-out-date').value;
        const paymentType = document.querySelector('input[name="payment-type"]:checked').value;

        if (!customerID || !hotelNumber || !roomNumber || !checkInDate || !checkOutDate || !paymentType) {
            alert('Please fill in all fields.');
            return;
        }

        const bookingData = {
            customerID,
            hotelNumber,
            roomNumber,
            paymentType,
            checkInDate,
            checkOutDate,
            checkedOut: 0  // Always 0 for now
        };
        console.log('Sending booking data:', JSON.stringify(bookingData));

        fetch('/createBooking', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(bookingData),
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Booking created successfully.');
            } else {
                alert('Error creating booking.');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error creating booking.');
        });
    });
});