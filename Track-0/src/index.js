const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

console.log("System Check: Initializing Middleware...");

app.use(cors());

app.get('/api/classify', async (req, res) => {
    const { name } = req.query;

    if (!name) {
        return res.status(400).json({ status: "error", message: "Missing name" });
    }

    try {
        // Using a more robust fetch approach
        const apiUrl = `https://api.genderize.io?name=${encodeURIComponent(name)}`;
        const response = await fetch(apiUrl);
        const data = await response.json();

        if (!data.gender) {
            return res.status(200).json({ status: "error", message: "No prediction available" });
        }

        res.status(200).json({
            status: "success",
            data: {
                name: data.name,
                gender: data.gender,
                probability: data.probability,
                sample_size: data.count,
                is_confident: data.probability >= 0.7 && data.count >= 100,
                processed_at: new Date().toISOString()
            }
        });
    } catch (error) {
        res.status(502).json({ status: "error", message: "External API error" });
    }
});

// THIS IS THE MOST IMPORTANT PART
app.listen(PORT, '0.0.0.0', () => {
    console.log(`\n🚀 WIZARD SERVER IS RUNNING!`);
    console.log(`🔗 Local URL: http://localhost:${PORT}/api/classify?name=john`);
    console.log(`Press Ctrl + C to stop\n`);
});