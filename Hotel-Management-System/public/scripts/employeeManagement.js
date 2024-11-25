const formContainer = document.getElementById('form-container');

document.getElementById('add-employee-btn').addEventListener('click', () => {
    formContainer.innerHTML = `
        <h3>Add Employee</h3>
        <label for="hotel-number">Hotel Number:</label>
        <input type="text" id="hotel-number">
        <label for="first-name">First Name:</label>
        <input type="text" id="first-name">
        <label for="last-name">Last Name:</label>
        <input type="text" id="last-name">
        <label for="department">Department:</label>
        <input type="text" id="department">
        <button id="submit-add">Submit</button>
    `;

    document.getElementById('submit-add').addEventListener('click', () => {
        const hotelNumber = document.getElementById('hotel-number').value;
        const firstName = document.getElementById('first-name').value;
        const lastName = document.getElementById('last-name').value;
        const department = document.getElementById('department').value;

        fetch('/add-employee', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ hotelNumber, firstName, lastName, department }),
        })
        .then(response => response.json())
        .then(data => alert(data.message))
        .catch(error => console.error('Error:', error));
    });
});

document.getElementById('delete-employee-btn').addEventListener('click', () => {
    formContainer.innerHTML = `
        <h3>Delete Employee</h3>
        <label for="employee-id">Employee ID:</label>
        <input type="text" id="employee-id">
        <button id="submit-delete">Delete</button>
    `;

    document.getElementById('submit-delete').addEventListener('click', () => {
        const employeeId = document.getElementById('employee-id').value;

        fetch(`/delete-employee/${employeeId}`, {
            method: 'DELETE',
        })
        .then(response => response.json())
        .then(data => alert(data.message))
        .catch(error => console.error('Error:', error));
    });
});

document.getElementById('update-employee-btn').addEventListener('click', () => {
    formContainer.innerHTML = `
        <h3>Update Employee</h3>
        <label for="employee-id">Employee ID:</label>
        <input type="text" id="employee-id">
        <label for="hotel-number">Hotel Number:</label>
        <input type="text" id="hotel-number">
        <label for="first-name">First Name:</label>
        <input type="text" id="first-name">
        <label for="last-name">Last Name:</label>
        <input type="text" id="last-name">
        <label for="department">Department:</label>
        <input type="text" id="department">
        <button id="submit-update">Update</button>
    `;

    document.getElementById('submit-update').addEventListener('click', () => {
        const employeeId = document.getElementById('employee-id').value;
        const hotelNumber = document.getElementById('hotel-number').value;
        const firstName = document.getElementById('first-name').value;
        const lastName = document.getElementById('last-name').value;
        const department = document.getElementById('department').value;

        fetch('/update-employee', {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ employeeId, hotelNumber, firstName, lastName, department }),
        })
        .then(response => response.json())
        .then(data => alert(data.message))
        .catch(error => console.error('Error:', error));
    });
});


document.getElementById('get-employee-btn').addEventListener('click', () => {
    const formContainer = document.getElementById('form-container');
    
    formContainer.innerHTML = `
        <h3>Search Employee</h3>
        <label for="employee-id">Enter Employee ID:</label>
        <input type="text" id="employee-id" placeholder="Enter Employee ID">
        <button id="search-employee-btn">Get Employee Details</button>
    `
    document.getElementById('search-employee-btn').addEventListener('click', async () => {
        const employeeId = document.getElementById('employee-id').value.trim(); 

        if (!employeeId) {
            alert('Employee id required!');
            return;
        }
        try { 
            const response = await fetch(`/employee/${employeeId}`);
            if (response.ok) {
                const employeeData = await response.json(); 
                if (employeeData) {
                    displayEmployeeDetails(employeeData);  
                } else {
                    alert('Employee not found');
                }
            } else {
                alert('Error fetching employee data');
            }
        } catch (error) {
            console.error('Error:', error);
            alert('An error occurred while fetching employee details.');
        }
    
    });
});
    

function displayEmployeeDetails(employeeData) {
    const employeeDetailsDiv = document.getElementById('form-container');

    employeeDetailsDiv.innerHTML = '';

    const employeeDiv = document.createElement('div');
    employeeDiv.innerHTML = `
        <h3>Employee Details</h3>
        <p><strong>ID:</strong> ${employeeData.employeeId}</p>
        <p><strong>First Name:</strong> ${employeeData.fname}</p>
        <p><strong>Last Name:</strong> ${employeeData.lname}</p>
        <p><strong>Works At:</strong> ${employeeData.hotelName}</p>
        <p><strong>In Department:</strong> ${employeeData.dep}</p>
    `;

    employeeDetailsDiv.appendChild(employeeDiv);
}