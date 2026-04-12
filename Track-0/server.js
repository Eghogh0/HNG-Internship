const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({ origin: '*' }));
app.use(express.json());

app.get('/api/classify', async (req, res) => {
  try {
    const { name } = req.query;

    if (name === undefined || name === null || name.trim() === '') {
      return res.status(400).json({
        status: 'error',
        message: 'Missing or empty name parameter'
      });
    }

    if (typeof name !== 'string') {
      return res.status(422).json({
        status: 'error',
        message: 'name is not a string'
      });
    }

    let response;
    try {
      response = await axios.get(`https://api.genderize.io/?name=${encodeURIComponent(name)}`, {
        timeout: 3000,
      });
    } catch (err) {
      console.error('Genderize API error:', err.message);
      return res.status(502).json({
        status: 'error',
        message: 'Upstream service error'
      });
    }

    const data = response.data;

    if (data.gender === null || data.count === 0) {
      return res.status(422).json({
        status: 'error',
        message: 'No prediction available for the provided name'
      });
    }

    const gender = data.gender;
    const probability = data.probability;
    const sample_size = data.count;
    const is_confident = (probability >= 0.7 && sample_size >= 100);
    const processed_at = new Date().toISOString();

    return res.status(200).json({
      status: 'success',
      data: {
        name: name.trim(),
        gender,
        probability,
        sample_size,
        is_confident,
        processed_at
      }
    });

  } catch (err) {
    console.error('Unhandled error:', err);
    return res.status(500).json({
      status: 'error',
      message: 'Internal server error'
    });
  }
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});