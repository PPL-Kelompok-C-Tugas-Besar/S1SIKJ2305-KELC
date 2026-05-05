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

app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/products', productRoutes);
app.use('/checkout', checkoutRoutes);
app.use('/cart', cartRoutes);

app.get('/', (req, res) => {
  res.json({ success: true, message: 'Gymbro API is running 🚀' });
});

// ==========================================
// 🚀 FITUR AZRIEL
// ==========================================

// Ambil semua latihan
app.get('/admin/exercises', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM exercises ORDER BY created_at DESC');
    res.json({ status: "sukses", data: rows });
  } catch (error) {
    res.status(500).json({ status: "gagal", pesan: error.message });
  }
});

// Tambah latihan
app.post('/admin/exercises', async (req, res) => {
  const { nama_latihan, tipe, target_otot, deskripsi_teknis } = req.body;
  try {
    const query = 'INSERT INTO exercises (nama_latihan, tipe, target_otot, deskripsi_teknis) VALUES (?, ?, ?, ?)';
    const [result] = await db.query(query, [nama_latihan, tipe, target_otot, deskripsi_teknis]);
    res.status(201).json({ status: "sukses", insertedId: result.insertId });
  } catch (error) {
    res.status(500).json({ status: "gagal", pesan: error.message });
  }
});

// Upload media
app.post('/admin/exercises/:id/media', upload.single('media_file'), async (req, res) => {
  const { id } = req.params;

  if (!req.file) {
    return res.status(400).json({ status: "gagal", pesan: "File tidak ditemukan" });
  }

  try {
    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: 'gymbro_exercises',
      resource_type: "auto"
    });

    const [update] = await db.query(
      'UPDATE exercises SET media_url = ? WHERE id = ?',
      [result.secure_url, id]
    );

    if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);

    if (update.affectedRows === 0) {
      return res.status(404).json({ status: "gagal", pesan: "ID Latihan tidak ditemukan" });
    }

    res.status(200).json({
      status: "sukses",
      pesan: "Upload berhasil!",
      url: result.secure_url
    });

  } catch (error) {
    if (req.file && fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
    res.status(500).json({ status: "gagal", pesan: error.message });
  }
});

app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Endpoint tidak ditemukan' });
});

// Start server
const start = async () => {
  try {
    await testConnection();
    app.listen(PORT, () => {
      console.log(`✅ Server running on http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error('Gagal start server:', err.message);
  }
};

start();