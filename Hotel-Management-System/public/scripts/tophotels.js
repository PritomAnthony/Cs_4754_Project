document.addEventListener('DOMContentLoaded', () => {
    const hotelListDiv = document.getElementById('top-hotels-list');
        fetch('/tophotels')
        .then(response => response.json())
        .then(hotels => {
            hotelListDiv.innerHTML = '';

            if (hotels.length > 0) {
                const list = document.createElement('ol');
                hotels.forEach(hotel => {
                    const listItem = document.createElement('li');
                    listItem.textContent = `${hotel.hotelName}`;
                    list.appendChild(listItem);
                });
                hotelListDiv.appendChild(list);
            } else {
                hotelListDiv.innerHTML = '<p>No hotels found.</p>';
            }
        })
        .catch(error => {
            console.error('Error fetching hotels:', error);
            hotelListDiv.innerHTML = '<p>Error loading hotels.</p>';
        });
    });

