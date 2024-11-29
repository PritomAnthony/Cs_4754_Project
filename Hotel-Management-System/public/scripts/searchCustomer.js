document.addEventListener('DOMContentLoaded', () => {
    // Search customer functionality
    document.getElementById('search-customer-btn').addEventListener('click', () => {
        const firstName = document.getElementById('first-name').value.trim();
        const lastName = document.getElementById('last-name').value.trim();
        const telephoneNumber = document.getElementById('telephone-number').value.trim();
        const postalCode = document.getElementById('postal-code').value.trim();

        if (!firstName && !lastName && !telephoneNumber) {
            alert('Please provide at least one search parameter.');
            return;
        }

        // Construct the query parameters based on the input fields
        const searchParams = new URLSearchParams();
        if (firstName) searchParams.append('firstName', firstName);
        if (lastName) searchParams.append('lastName', lastName);
        if (telephoneNumber) searchParams.append('telephone', telephoneNumber);

        // Send a request to the /checkCustomer route
        fetch(`/checkCustomer?${searchParams.toString()}`)
            .then(response => response.json())
            .then(data => {
                const resultsDiv = document.getElementById('customer-results');
                const registrationDiv = document.getElementById('customer-registration');
                resultsDiv.innerHTML = ''; // Clear previous results

                if (data.customerID) {
                    // Customer found, create a new div to show the customer ID
                    const customerDiv = document.createElement('div');
                    customerDiv.textContent = `Customer found. ID: ${data.customerID}`;
                    resultsDiv.appendChild(customerDiv);

                    // Hide the registration section if customer found
                    registrationDiv.style.display = 'none';
                } else {
                    // Customer not found, show the registration section and hide results
                    const messageDiv = document.createElement('div');
                    messageDiv.textContent = 'No customers found with the provided details. Please register below.';
                    resultsDiv.appendChild(messageDiv);

                    // Show the registration section
                    registrationDiv.style.display = 'block';
                }
            })
            .catch(error => {
                console.error('Error searching for customer:', error);
                alert('An error occurred while searching for the customer.');
            });
    });

    // Postal code real-time validation
    document.getElementById('postal-code').addEventListener('input', (event) => {
        const postalCode = event.target.value.trim();
    
        // Regex to check postal code format (e.g., P4A 1L1)
        const postalCodePattern = /^[A-Za-z]\d[A-Za-z] \d[A-Za-z]\d$/;
    
        // Check if the postal code matches the pattern
        if (!postalCodePattern.test(postalCode) && postalCode.length > 0) {
            // Show error if format is incorrect
            showPostalCodeError('Postal code must be in the format: P4A 1L1');
        } else {
            // Clear any previous error message if format is correct
            clearPostalCodeError();
        }
    });

    // Function to show error message for postal code field
    function showPostalCodeError(message) {
        const errorDiv = document.getElementById('postal-code-error');
        if (!errorDiv) {
            const newErrorDiv = document.createElement('div');
            newErrorDiv.id = 'postal-code-error';
            newErrorDiv.style.color = 'red';
            newErrorDiv.textContent = message;
            document.getElementById('registration-form').appendChild(newErrorDiv);
        } else {
            errorDiv.textContent = message;
        }
    }

    // Function to clear error message for postal code
    function clearPostalCodeError() {
        const errorDiv = document.getElementById('postal-code-error');
        if (errorDiv) {
            errorDiv.remove();
        }
    }

    // Handle the registration form submission
    document.getElementById('registration-form').addEventListener('submit', (event) => {
        event.preventDefault();

        const firstName = document.getElementById('first-name').value.trim();
        const lastName = document.getElementById('last-name').value.trim();
        const telephoneNumber = document.getElementById('telephone-number').value.trim();
        const street = document.getElementById('street').value.trim();
        const city = document.getElementById('city').value.trim();
        const province = document.getElementById('province').value.trim();
        const postalCode = document.getElementById('postal-code').value.trim();
        // Send the registration data to the backend
        const registrationData = {
            firstName: firstName,
            lastName: lastName,
            telephone: telephoneNumber,
            street: street,
            city: city,
            province: province,
            postalCode: postalCode
        };

        fetch('/registrationCustomer', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(registrationData)
        })
        .then(response => response.json())
        .then(data => {
            const regDiv = document.getElementById('reg-result');
            regDiv.innerHTML = ''; // Clear previous results

            if (data.customerID) {
                const regSuccess = document.createElement('div');
                regSuccess.textContent = `Registration successful for ${firstName} ${lastName} with Customer ID: ${data.customerID}`; 
                regDiv.appendChild(regSuccess);
            } else {
                alert('Error during registration.');
            }
        })
        .catch(error => {
            console.error('Error registering customer:', error);
            alert('An error occurred during registration.');
        });
    });
});
