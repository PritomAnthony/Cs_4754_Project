document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('add-order-btn').addEventListener('click', () => {
        const bookingNumber = parseInt(document.getElementById('order-booking-number').value.trim(), 10);
        const price = parseFloat(document.getElementById('price').value.trim());
        console.log(bookingNumber);
        console.log(price);
        if (!bookingNumber || !price) {
            alert('Please fill in all fields.');
            return;
        }

        const orderData = {
            bookingNumber,
            price
        };
        console.log('Sending food order data:', JSON.stringify(orderData));

        fetch('/addFoodOrder', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(orderData),
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert(`Food order created successfully with order ID ${data.orderID}`);
            }
            else {
                alert('Error creating food order');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error creating food order.')
        })
    })
})