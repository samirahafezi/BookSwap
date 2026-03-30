// Hamburger Menu Functionality

document.addEventListener('DOMContentLoaded', function() {
    const hamburger = document.querySelector('.hamburger-menu');
    const menu = document.querySelector('.nav-menu');

    if (hamburger && menu) {
        hamburger.addEventListener('click', function() {
            menu.classList.toggle('open');
        });
    }
});
