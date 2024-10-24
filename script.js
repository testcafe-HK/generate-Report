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
    const responseDisplay = document.getElementById('responseDisplay'); // Div to display the response
    responseDisplay.innerHTML = '<p>Loading... Please wait.</p>'; // Show loading message

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
            
            // Display the success message on the page
            responseDisplay.innerHTML = `<p style="color:green;">Success: ${JSON.stringify(result)}</p>`;
        } else {
            console.error('Error:', response.statusText);
            // Display the error message on the page
            responseDisplay.innerHTML = `<p style="color:red;">Error: ${response.statusText}</p>`;
        }
    } catch (error) {
        console.error('Request failed:', error);
        // Display a general error message on the page
        responseDisplay.innerHTML = `<p style="color:red;">Error occurred while submitting form. ${error}</p>`;
    }
}
