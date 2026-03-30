// Basic JavaScript functionality for navigation

function navigateTo(section) {
    // Get all sections
    const sections = document.querySelectorAll('section');
    
    // Hide all sections
    sections.forEach(sec => {
        sec.style.display = 'none';
    });
    
    // Show the selected section
    const selectedSection = document.getElementById(section);
    if (selectedSection) {
        selectedSection.style.display = 'block';
    }
}

// Example usage:
// navigateTo('home'); // Call this function to show the home section
