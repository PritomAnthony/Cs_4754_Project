document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('search-order-btn').addEventListener('click', () => {
        const orderDiv = document.getElementById('order-div');
        const orderID = document.getElementById('search-order-id').value.trim();
        const bookingNumber = document.getElementById('update-order-booking-number');
        const price = document.getElementById('update-order-price');
        const date = document.getElementById('update-order-date');
        fetch(`/viewFoodOrder/${orderID}`)
        .then(response => response.json())
        .then(order => {
            orderDiv.innerHTML = '';

            if (order) {
                const orderDate = order.orderDate;
                const formattedDate = new Date(orderDate).toISOString().split('T')[0];
                
                document.getElementById('update-food-order').style.display= 'block';
                bookingNumber.value = `${order.bookingNumber}`;
                price.value = `${order.price}`;
                date.value = `${formattedDate}`
            } else {
                orderDiv.innerHTML = '<p>No food order found.</p>';
            }
        })
        .catch(error => {
            document.getElementById('update-food-order').style.display= 'none';
            console.error('No food order found:', error);
            orderDiv.innerHTML = '<p>No food order found.</p>';
        })
    });
});
