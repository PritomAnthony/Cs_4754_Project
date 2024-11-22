document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('search-customer-btn').addEventListener('click', () => {
        let firstName = document.getElementById('first-name').value.trim();
        let lastName = document.getElementById('last-name').value.trim();
        let postalCode = document.getElementById('post-code').value.trim();

        if (!firstName || !lastName || !postalCode) {
            alert('Please fill in all fields.');
            return;
        }

        // sending data to the server 
        fetch(`/checkCustomer?firstName=${encodeURIComponent(firstName)}&lastName=${encodeURIComponent(lastName)}&postalCode=${encodeURIComponent(postalCode)}`)
            .then(response => {
                if (response.ok) {
                    return response.json();
                }
                throw new Error(response.statusText);
            })
            .then(data => {
                if (data.message) {
                    alert(data.message);                                          // message for existing or new customer
                } else {
                    alert('Unexpected response from the server.');
                }
            })
            .catch(error => {
                alert(`Error: ${error.message}`);
            });
    });
});
