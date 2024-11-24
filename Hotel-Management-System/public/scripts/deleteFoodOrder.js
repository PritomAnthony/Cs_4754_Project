document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('delete-order-btn').addEventListener('click', () => {
        const orderID = document.getElementById('delete-order-id').value.trim();

        if (!orderID) {
            alert('Please enter an order ID.');
            return;
        }

        fetch(`/deleteFoodOrder/${orderID}`, {
            method: 'DELETE',
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Food order deleted successfully.');
            } else {
                alert('Error deleting food order.');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error deleting food order.');
        });
    });
});