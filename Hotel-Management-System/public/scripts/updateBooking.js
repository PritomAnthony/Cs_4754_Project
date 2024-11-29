document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('update-booking-btn').addEventListener('click', () => {
        const bookingNumber = document.getElementById('update-booking-number').value.trim();
        const customerID = parseInt(document.getElementById('update-customer-id').value.trim(), 10);
        const hotelNumber = parseInt(document.getElementById('update-hotel-number-booking').value.trim(), 10);
        const roomNumber = parseInt(document.getElementById('update-room-number').value.trim(), 10);
        const checkInDate = document.getElementById('update-check-in-date').value.trim();
        const checkOutDate = document.getElementById('update-check-out-date').value.trim();
        const paymentType = document.querySelector('input[name="update-payment-type"]:checked').value;
        
        fetch(`/updateBooking`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ bookingNumber, customerID, hotelNumber, roomNumber, checkInDate, checkOutDate, paymentType }),
        })
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                alert('Booking updated successfully!');
            } else {
                alert('Failed to update booking.');
            }
        })
        .catch(error => {
            console.error('Error updating booking:', error);
            alert('An error occurred while updating the booking.');
        })
    });
});
