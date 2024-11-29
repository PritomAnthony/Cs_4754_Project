document.addEventListener('DOMContentLoaded', () => {
    document.getElementById("generate-bill-btn").addEventListener('click', () => {
        let bookingNumber = document.getElementById('generate-bill-input').value.trim();
        if (!bookingNumber) {
            alert('Please input the booking number');
            return;
        }

        // Fetch the data for the bill details from the server
        fetch(`/generateBill/${encodeURIComponent(bookingNumber)}`)
        .then(response => {
            console.log('Response from server:', response);
            if (response.ok) {
                return response.json();
            }
            throw new Error('Error generating bill');
        })
        .then(data => {
            if (data.billDetails && data.totalFees !== undefined) {
                const billDetails = data.billDetails;
                const totalFees = data.totalFees;

                // Update the booking number
                document.getElementById('bill-booking-number').textContent = document.getElementById("generate-bill-input").value.trim();

                // Loop through the bill details and display them in the appropriate <span> elements
                billDetails.forEach(detail => {
                    if (detail.Label === 'Total room cost: ') {
                        document.getElementById('room-cost').textContent = detail.COST;
                    } else if (detail.Label === 'Total food order cost: ') {
                        document.getElementById('food-cost').textContent = detail.COST;
                    }
                });

                // Display the total fees in the 'total-cost' span
                document.getElementById('total-cost').textContent = totalFees;

                // Show the bill details section
                document.getElementById('billDetails').style.display = 'block';
            } else {
                alert('No bill details found for this booking');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('There was an error generating the bill.' + error.message);
        });
    });
});
