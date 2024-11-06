const express = require('express');
const app = express();
const PORT = 3000;

// Middleware to parse JSON bodies
app.use(express.json());

// Define the API endpoint
app.post('/api/your-endpoint', (req, res) => {
    // Access the JSON data sent in the POST request
    const data = req.body;

    // Process the data (example: echo back the data)
    const response = {
        received_data: data
    };

    // Send a JSON response
    res.status(200).json(response);
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
