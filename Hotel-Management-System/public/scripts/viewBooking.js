document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('search-booking-btn').addEventListener('click', () => {
        const bookingDiv = document.getElementById('update-div');
        const bookingNumber = document.getElementById('update-booking-number').value.trim();
        const customerID = document.getElementById('update-customer-id');
        const hotelNumber = document.getElementById('update-hotel-number-booking');
        const roomNumber = document.getElementById('update-room-number');
        const checkInDate = document.getElementById('update-check-in-date');
        const checkOutDate = document.getElementById('update-check-out-date');
        fetch(`/viewBooking/${bookingNumber}`)
        .then(response => response.json())
        .then(booking => {
            bookingDiv.innerHTML = '';

            if (booking) {
                document.getElementById('update-booking').style.display= 'block';
                const formattedInDate = new Date(booking.checkInDate).toISOString().split('T')[0];
                const formattedOutDate = new Date(booking.checkOutDate).toISOString().split('T')[0];

                customerID.value = `${booking.customerID}`;
                hotelNumber.value = `${booking.hotelNumber}`;
                roomNumber.value = `${booking.roomNumber}`;
                checkInDate.value = `${formattedInDate}`;
                checkOutDate.value = `${formattedOutDate}`;
                document.querySelectorAll('input[name="update-payment-type"]').forEach(radio => {
                    if (radio.value === booking.paymentType) {
                        radio.checked = true;
                    }
                });
                // const bookingTable = document.createElement('table');
                // const tableHeader = document.createElement('thead');

                // tableHeader.innerHTML = `
                //     <tr>
                //         <th>Booking Number</th>
                //         <th>Customer ID</th>
                //         <th>Hotel Number</th>
                //         <th>Room Number</th>
                //         <th>Payment Type</th>
                //         <th>Check-In Date</th>
                //         <th>Check-Out Date</th>
                //         <th>Checked Out</th>
                //         <th>Room Cost</th>
                //     </tr>
                // `;
                // bookingTable.appendChild(tableHeader);

                // const tableBody = document.createElement('tbody');
                // const row = document.createElement('tr');
                // row.innerHTML = `
                //     <td>${booking.bookingNumber}</td>
                //     <td>${booking.customerID}</td>
                //     <td>${booking.hotelNumber}</td>
                //     <td>${booking.roomNumber}</td>
                //     <td>${booking.paymentType}</td>
                //     <td>${new Date(booking.checkInDate).toLocaleDateString()}</td>
                //     <td>${new Date(booking.checkOutDate).toLocaleDateString()}</td>
                //     <td>${booking.checkedOut ? 'Yes' : 'No'}</td>
                //     <td>${booking.roomCost}</td>
                // `;
                // tableBody.appendChild(row);
                // bookingTable.appendChild(tableBody);
                // bookingDiv.appendChild(bookingTable);
            } else {
                document.getElementById('update-booking').style.display= 'none';
                bookingDiv.innerHTML = '<p>No booking found.</p>';
            }
        })
        .catch(error => {
            document.getElementById('update-booking').style.display= 'none';
            console.error('No booking found:', error);
            bookingDiv.innerHTML = '<p>No booking found.</p>';
        })
    });
});
