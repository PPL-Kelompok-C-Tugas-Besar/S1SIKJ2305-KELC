require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { testConnection } = require('./config/db');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');

app.get('/', (req, res) => {
  res.json({ success: true, message: 'Gymbro API is running' });
});

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

const start = async () => {
  await testConnection();
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
};

start();