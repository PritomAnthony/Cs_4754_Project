document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('search-booking-btn').addEventListener('click', () => {
        const bookingDiv = document.getElementById('booking-div');
        const bookingNumber = document.getElementById('search-booking-number').value.trim();
        fetch(`/viewBooking/${bookingNumber}`)
        .then(response => response.json())
        .then(booking => {
            bookingDiv.innerHTML = '';

            if (booking) {
                const bookingTable = document.createElement('table');
                const tableHeader = document.createElement('thead');

                tableHeader.innerHTML = `
                    <tr>
                        <th>Booking Number</th>
                        <th>Customer ID</th>
                        <th>Hotel Number</th>
                        <th>Room Number</th>
                        <th>Payment Type</th>
                        <th>Check-In Date</th>
                        <th>Check-Out Date</th>
                        <th>Checked Out</th>
                        <th>Room Cost</th>
                    </tr>
                `;
                bookingTable.appendChild(tableHeader);

                const tableBody = document.createElement('tbody');
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${booking.bookingNumber}</td>
                    <td>${booking.customerID}</td>
                    <td>${booking.hotelNumber}</td>
                    <td>${booking.roomNumber}</td>
                    <td>${booking.paymentType}</td>
                    <td>${new Date(booking.checkInDate).toLocaleDateString()}</td>
                    <td>${new Date(booking.checkOutDate).toLocaleDateString()}</td>
                    <td>${booking.checkedOut ? 'Yes' : 'No'}</td>
                    <td>${booking.roomCost}</td>
                `;
                tableBody.appendChild(row);
                bookingTable.appendChild(tableBody);
                bookingDiv.appendChild(bookingTable);
            } else {
                bookingDiv.innerHTML = '<p>No booking found.</p>';
            }
        })
        .catch(error => {
            console.error('Error fetching booking:', error);
            bookingDiv.innerHTML = '<p>Error fetching booking.</p>';
        })
    });
});
