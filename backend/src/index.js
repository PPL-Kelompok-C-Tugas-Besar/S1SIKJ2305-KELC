require('dotenv').config();
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

// 1. Hubungkan ke Database Samuel (pool dialias jadi 'db')
const { pool: db, testConnection } = require('./config/db'); 

// 2. Persiapan Media Tools
const cloudinary = require('cloudinary').v2;
const multer = require('multer');

// Pastikan folder 'uploads' ada biar gak error saat upload
const uploadDir = './uploads';
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
}

// Konfigurasi Cloudinary (Otomatis baca CLOUDINARY_URL di .env)
cloudinary.config(true);
const upload = multer({ dest: 'uploads/' });

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Endpoint Utama
app.get('/', (req, res) => {
  res.json({ success: true, message: 'Gymbro API is running with Cloudinary 🚀' });
});

// ==========================================
// 🚀 FITUR AZRIEL (PBI-01 & PBI-02)
// ==========================================

// PBI-01: Ambil Semua Data Latihan
app.get('/admin/exercises', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM exercises ORDER BY created_at DESC');
        res.json({ status: "sukses", data: rows });
    } catch (error) {
        res.status(500).json({ status: "gagal", pesan: error.message });
    }
});

// PBI-01: Tambah Latihan Baru (Biar dapet ID buat upload media)
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

// PBI-02: Upload Media ke Cloudinary
app.post('/admin/exercises/:id/media', upload.single('media_file'), async (req, res) => {
    const { id } = req.params;
    
    if (!req.file) {
        return res.status(400).json({ status: "gagal", pesan: "File tidak ditemukan" });
    }

    try {
        // 1. Upload ke folder 'gymbro_exercises' di cloud
        const result = await cloudinary.uploader.upload(req.file.path, {
            folder: 'gymbro_exercises',
            resource_type: "auto"
        });

        // 2. Update media_url di tabel MySQL
        const [update] = await db.query('UPDATE exercises SET media_url = ? WHERE id = ?', [result.secure_url, id]);

        // Hapus file sampah di laptop
        if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);

        if (update.affectedRows === 0) {
            return res.status(404).json({ status: "gagal", pesan: "ID Latihan tidak ditemukan" });
        }

        res.status(200).json({
            status: "sukses",
            pesan: "PBI-02 Berhasil! File masuk ke Cloudinary dan DB",
            url: result.secure_url
        });
    } catch (error) {
        if (req.file && fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
        res.status(500).json({ status: "gagal", pesan: "Error: " + error.message });
    }
});



const start = async () => {
  try {
    await testConnection();
    app.listen(PORT, () => {
      console.log(`✅ Gymbro Server Running on http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error('Gagal menyalakan server:', err.message);
  }
};

start();