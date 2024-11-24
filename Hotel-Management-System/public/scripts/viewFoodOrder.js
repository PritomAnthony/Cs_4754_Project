document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('search-order-btn').addEventListener('click', () => {
        const orderDiv = document.getElementById('order-div');
        const orderID = document.getElementById('search-order-id').value.trim();
        fetch(`/viewFoodOrder/${orderID}`)
        .then(response => response.json())
        .then(order => {
            orderDiv.innerHTML = '';

            if (order) {
                const orderTable = document.createElement('table');
                const tableHeader = document.createElement('thead');

                tableHeader.innerHTML = `
                    <tr>
                        <th>Order ID</th>
                        <th>Booking Number</th>
                        <th>Price</th>
                        <th>Order Date</th>
                    </tr>
                `;
                orderTable.appendChild(tableHeader);

                const tableBody = document.createElement('tbody');
                const row = document.createElement('tr');
                const orderDate = order.orderDate;
                const formattedDate = new Date(orderDate).toISOString().split('T')[0];
                row.innerHTML = `
                    <td>${order.orderID}</td>
                    <td>${order.bookingNumber}</td>
                    <td>${order.price}</td>
                    <td>${formattedDate}</td>
                `;
                tableBody.appendChild(row);
                orderTable.appendChild(tableBody);
                orderDiv.appendChild(orderTable);
            } else {
                orderDiv.innerHTML = '<p>No food order found.</p>';
            }
        })
        .catch(error => {
            console.error('Error fetching food order:', error);
            orderDiv.innerHTML = '<p>Error fetching food order.</p>';
        })
    });
});
