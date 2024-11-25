
document.addEventListener('DOMContentLoaded', () => {
    const hotelsButton = document.getElementById('hotels-btn');
    const hotelListDiv = document.getElementById('hotel-list');
    
    hotelsButton.addEventListener('click', () => {
        fetch('/hotels')
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
});
