// Fetch data from JSON file
fetch('data.json')
    .then(response => response.json())
    .then(json => {
        const data = json.data;
        const details = json.details;
        const total = data.datasets[0].data.reduce((acc, curr) => acc + curr, 0); // Calculate total

        const ctx = document.getElementById('myChart').getContext('2d');

        // Create the chart
        const myDoughnutChart = new Chart(ctx, {
            type: 'doughnut',
            data: data,
            options: {
                onClick: (event) => {
                    const activePoints = myDoughnutChart.getElementsAtEventForMode(event, 'nearest', { intersect: true }, true);
                    if (activePoints.length) {
                        const index = activePoints[0].index;
                        document.getElementById('details').innerHTML = details[index];

                        // Redirect if the clicked slice is 'Yellow'
                        if (myDoughnutChart.data.labels[index] === 'Yellow') {
                            window.location.href = 'https://example.com'; // Link for the dynamic slice
                        }
                    }
                },
                plugins: {
                    tooltip: {
                        callbacks: {
                            label: function(tooltipItem) {
                                const label = tooltipItem.label || '';
                                const value = tooltipItem.raw || 0;
                                return `${label}: ${value}`;
                            }
                        }
                    }
                }
            }
        });

        // Display the total in the center
        document.getElementById('total').innerText = `Total: ${total}`;
    })
    .catch(error => {
        console.error('Error fetching data:', error);
    });
