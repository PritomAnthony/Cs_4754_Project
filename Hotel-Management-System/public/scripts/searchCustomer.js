document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('search-customer-btn').addEventListener('click', () => {
        let firstName = document.getElementById('first-name').value.trim();
        let lastName = document.getElementById('last-name').value.trim();
        let postalCode = document.getElementById('post-code').value.trim();
    
        if (!firstName || !lastName || !postalCode) {
        alert('Please fill in all fields.');
        return;
        }
    
        // Send data to the server using fetch (GET request)
        fetch(`/checkCustomer?firstName=${encodeURIComponent(firstName)}&lastName=${encodeURIComponent(lastName)}&postalCode=${encodeURIComponent(postalCode)}`)
        .then(response => {
            if (response.ok) {
            return response.json();
            }
            throw new Error('Customer not found');
        })
        .then(data => {
            if (data.customerID) {
            alert(`Customer ID: ${data.customerID}`);
            } else {
            alert('Customer not found. Please register.');
            }
        })
        .catch(error => {
            alert(error.message);
        });
    });

});