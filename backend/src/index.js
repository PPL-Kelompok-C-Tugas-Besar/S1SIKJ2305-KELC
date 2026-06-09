require('dotenv').config();
const express = require('express');
const cors = require('cors');
const fs = require('fs');

// 1. Hubungkan ke Database
const { pool: db, testConnection } = require('./config/db');

// Routes
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const productRoutes = require('./routes/productRoutes');
const checkoutRoutes = require('./routes/checkoutRoutes');
const cartRoutes = require('./routes/cartRoutes');
const exerciseRoutes = require('./routes/exerciseRoutes');
const workoutRoutes = require('./routes/workoutRoutes');
const calorieRoutes = require('./routes/calorieRoutes'); // PBI-1 [Subtask 2]

// 2. Media Tools
const cloudinary = require('cloudinary').v2;
const multer = require('multer');

// Pastikan folder 'uploads' ada
const uploadDir = './uploads';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

// Config Cloudinary
cloudinary.config(true);
const upload = multer({ dest: 'uploads/' });

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/products', productRoutes);
app.use('/checkout', checkoutRoutes);
app.use('/cart', cartRoutes);
const adminRoutes = require('./routes/adminRoutes');

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

const start = async () => {
  await testConnection();
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
};

start();