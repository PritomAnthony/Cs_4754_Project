document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('update-order-btn').addEventListener('click', () => {
        const orderID = document.getElementById('search-order-id').value.trim();
        const bookingNumber = document.getElementById('update-order-booking-number').value.trim();
        const price = document.getElementById('update-order-price').value.trim();
        const date = document.getElementById('update-order-date').value.trim();

        fetch(`/updateFoodOrder`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ orderID, bookingNumber, price, orderDate: date }),
        })
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                alert('Food order updated successfully!');
            } else {
                alert('Failed to update food order.');
            }
        })
        .catch(error => {
            console.error('Error updating food order:', error);
            alert('An error occurred while updating the food order.');
        })
    });
});