// Функция для отображения списка мероприятий
function displayEvents(events) {
    const eventsList = document.getElementById('events-list');
    eventsList.innerHTML = '';
    events.forEach(event => {
        const eventItem = document.createElement('div');
        eventItem.innerHTML = `
            <h2>${event.title}</h2>
            <p>Описание: ${event.description}</p>
            <p>Дата: ${event.date}</p>
            <p>Местоположение: ${event.location.lat}, ${event.location.lng}</p>
        `;
        eventsList.appendChild(eventItem);
    });
}

// Функция для сортировки мероприятий по дате
function sortByDate(events) {
    return events.sort((a, b) => new Date(a.date) - new Date(b.date));
}

// Функция для сортировки мероприятий по местоположению
function sortByLocation(events) {
    return events.sort((a, b) => a.location.lat - b.location.lat || a.location.lng - b.location.lng);
}

// Инициализация карты
ymaps.ready(init);

function init() {
    const myMap = new ymaps.Map('map', {
        center: [55.751244, 37.618423],
        zoom: 17
    });

    // Добавление маркеров на карту
    function addMarkersToMap(events) {
        events.forEach(event => {
            const marker = new ymaps.Placemark([event.location.lat, event.location.lng], {
                hintContent: event.title
            });
            myMap.geoObjects.add(marker);
        });
    }

    // Загрузка данных из файла events.json
    fetch('events.json')
        .then(response => response.json())
        .then(events => {
            displayEvents(events);
            addMarkersToMap(events);
        })
        .catch(error => console.error('Ошибка при загрузке данных:', error));
}

// Отображение мероприятий и добавление обработчиков сортировки
window.onload = () => {
    document.getElementById('sort-by-date').addEventListener('click', () => {
        fetch('events.json')
            .then(response => response.json())
            .then(events => displayEvents(sortByDate(events)))
            .catch(error => console.error('Ошибка при загрузке данных:', error));
    });

    document.getElementById('sort-by-location').addEventListener('click', () => {
        fetch('events.json')
            .then(response => response.json())
            .then(events => displayEvents(sortByLocation(events)))
            .catch(error => console.error('Ошибка при загрузке данных:', error));
    });
};