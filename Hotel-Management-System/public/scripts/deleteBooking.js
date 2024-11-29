document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('delete-booking-btn').addEventListener('click', () => {
        const bookingNumber = document.getElementById('delete-booking-number').value.trim();

        if (!bookingNumber) {
            alert('Please enter a booking number.');
            return;
        }

        deleteBtn = document.getElementById('delete-booking-btn');
        deleteBtn.disabled = true;

        fetch(`/deleteBooking/${bookingNumber}`, {
            method: 'DELETE',
        })
        .then(response => response.json())
        .then(data => {
            deleteBtn.disabled = false;
            if (data.success) {
                alert('Booking deleted successfully.');
            } else {
                alert(data.message || 'Error deleting booking.');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            deleteBtn.disabled = false;
            alert('Error deleting booking.');
        });
    });
});