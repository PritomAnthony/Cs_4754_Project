document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('delete-booking-btn').addEventListener('click', () => {
        const bookingNumber = document.getElementById('booking-number').value.trim();

        if (!bookingNumber) {
            alert('Please enter a booking number.');
            return;
        }

        fetch(`/deleteBooking/${bookingNumber}`, {
            method: 'DELETE',
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Booking deleted successfully.');
            } else {
                alert('Error deleting booking.');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error deleting booking.');
        });
    });
});