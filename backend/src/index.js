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
const voucherRoutes = require('./routes/voucherRoutes');

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
app.use(express.json({ limit: '5mb' }));

app.use('/products', productRoutes);
app.use('/checkout', checkoutRoutes);
app.use('/cart', cartRoutes);
app.use('/vouchers', voucherRoutes);
const adminRoutes = require('./routes/adminRoutes');

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/exercises', exerciseRoutes);
app.use('/api/workouts', require('./routes/workoutRoutes'));
app.use('/api/admin', adminRoutes);
app.use('/api/calories', calorieRoutes); // PBI-1 [Subtask 2] – Estimasi Kalori Terbakar
app.use('/api/marketplace', require('./routes/marketplaceRoutes'));

app.get('/', (req, res) => {
  res.json({ success: true, message: 'Gymbro API is running 🚀' });
});

// End of Admin Routes

app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Endpoint tidak ditemukan' });
});

// Start server
const start = async () => {
  try {
    await testConnection();

    // Jalankan migrasi tabel
    const { runMigration } = require('./config/migrate_history');
    await runMigration();

    const { runWeightMigration } = require('./config/migrate_weight');
    await runWeightMigration();

    const { runWorkoutsMigration } = require('./config/migrate_workouts');
    await runWorkoutsMigration();

    const { runExercisesMigration } = require('./config/migrate_exercises');
    await runExercisesMigration();

    // PBI-1 [Subtask 1] – Tambahkan kolom met_value ke tabel exercises
    const { runMetMigration } = require('./config/migrate_met');
    await runMetMigration();

    const { runPhotoMigration } = require('./config/migrate_photo');
    await runPhotoMigration();

    const { runAddressesMigration } = require('./config/migrate_addresses');
    await runAddressesMigration();
    // Migrasi PBI Rekomendasi Target Kalori
    const { runUsersCalorieMigration } = require('./config/migrate_users_calorie_target');
    await runUsersCalorieMigration();

    // Migrasi PBI Marketplace & Reviews & Wishlist
    const { runMarketplaceFeaturesMigration } = require('./config/migrate_marketplace_features');
    await runMarketplaceFeaturesMigration();

    const { runReviewsMigration } = require('./config/migrate_reviews');
    await runReviewsMigration();

    // Seed/verify default admin user
    const bcrypt = require('bcrypt');
    const crypto = require('crypto');
    const adminEmail = 'admin@gymbro.com';
    const adminPassword = 'admin123';
    try {
      const [existingAdmin] = await db.execute('SELECT id FROM users WHERE email = ?', [adminEmail]);
      if (existingAdmin.length > 0) {
        const hashedPassword = await bcrypt.hash(adminPassword, 10);
        await db.execute('UPDATE users SET role = \'admin\', password = ? WHERE email = ?', [hashedPassword, adminEmail]);
        console.log('✅ Admin user verified & password updated.');
      } else {
        const hashedPassword = await bcrypt.hash(adminPassword, 10);
        const adminId = crypto.randomUUID();
        await db.execute(
          'INSERT INTO users (id, full_name, email, password, role) VALUES (?, ?, ?, ?, ?)',
          [adminId, 'Gymbro Admin', adminEmail, hashedPassword, 'admin']
        );
        console.log('✅ Admin user created successfully.');
      }
    } catch (adminErr) {
      console.error('❌ Error seeding/verifying admin user:', adminErr.message);
    }

    app.listen(PORT, () => {
      console.log(`✅ Server running on http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error('Gagal start server:', err.message);
  }
};

start();
