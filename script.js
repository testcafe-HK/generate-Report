document.getElementById('myForm').addEventListener('submit', function(event) {
    event.preventDefault(); // Prevent the default form submission behavior
    
    // Get form data
    const textbox1 = document.getElementById('textbox1').value;
    const textbox2 = document.getElementById('textbox2').value;

    // Prepare the data to be sent in the request body
    const data = {
        field1: textbox1,
        field2: textbox2
    };

    // Call the function to make the API request
    submitFormData(data);
});

async function submitFormData(data) {
    try {
        // Make the API POST request
        const response = await fetch('https://example.com/api/endpoint', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer YOUR_TOKEN_HERE' // If needed
            },
            body: JSON.stringify(data)
        });

        // Check if the request was successful
        if (response.ok) {
            const result = await response.json();
            console.log('Success:', result);
            alert('Form submitted successfully!');
        } else {
            console.error('Error:', response.statusText);
            alert('Failed to submit form.');
        }
    } catch (error) {
        console.error('Request failed:', error);
        alert('Error occurred while submitting form.');
    }
}
