document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('search-room-btn').addEventListener('click', () => {
        let hotelNumber = document.getElementById('hotel-number-search').value.trim();
        let roomCategory = document.getElementById('room-category').value.trim();
        console.log(hotelNumber);
        console.log(roomCategory);
        const roomListDiv = document.getElementById('room-list');
        roomListDiv.innerHTML = '';

        if (!hotelNumber || !roomCategory) {
        alert('Please fill in all fields.');
        return;
        }
    
        fetch(`/availableRooms?hotelNumber=${encodeURIComponent(hotelNumber)}&roomCategory=${encodeURIComponent(roomCategory)}`)
            .then(response => {
                if (response.ok) {
                    return response.json();
                }
                throw new Error('Error fetching available rooms');
            })
            .then(data => {
                if (data.length > 0) {
                    const list = document.createElement('ul');
                    data.forEach(room => {
                        const listItem = document.createElement('li');
                        listItem.textContent = `${room.roomNumber}`;
                        list.appendChild(listItem);
                        console.log(`${room.roomNumber}`)
                    });
                    roomListDiv.appendChild(list);
                } else {
                    roomListDiv.innerHTML = '<p>No rooms found.</p>';
                }
                console.log(data);;
            })
            .catch(error => {
                const errorMessage = document.createElement('p');
                errorMessage.textContent = error.message;
                roomListDiv.appendChild(errorMessage);
            });
    });

});