require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const { pool } = require('../src/config/db');

const initDB = async () => {
  try {
    const createTableQuery = `
      CREATE TABLE IF NOT EXISTS produk (
        id INT AUTO_INCREMENT PRIMARY KEY,
        nama VARCHAR(255) NOT NULL,
        harga DECIMAL(12,2) NOT NULL,
        kategori VARCHAR(100),
        gambar VARCHAR(255),
        deskripsi TEXT
      );
    `;
    await pool.query(createTableQuery);
    console.log('✅ Tabel produk berhasil dibuat atau sudah ada.');

    // Cek apakah tabel kosong
    const [rows] = await pool.query('SELECT COUNT(*) as count FROM produk');
    if (rows[0].count === 0) {
      const insertQuery = `
        INSERT INTO produk (nama, harga, kategori, gambar, deskripsi) VALUES
        ('Optimum Whey', 850000.00, 'Protein', 'assets/whey.png', 'Premium whey protein untuk pertumbuhan otot maksimal. Cepat diserap oleh tubuh.'),
        ('Creatine Mono', 350000.00, 'Creatine', 'assets/creatine.png', 'Creatine monohydrate murni 100%. Meningkatkan kekuatan dan daya tahan saat latihan beban berat.'),
        ('Pre-Workout Blast', 450000.00, 'Pre-Workout', 'assets/whey.png', 'Energi meledak dan fokus tajam sebelum latihan intens. Tanpa gula tambahan.'),
        ('BCAA Plus', 300000.00, 'Amino Acids', 'assets/creatine.png', 'Membantu pemulihan otot lebih cepat dan mencegah penyusutan otot setelah latihan ekstrem.'),
        ('Mass Gainer Pro', 950000.00, 'Gainer', 'assets/whey.png', 'Suplemen kalori tinggi dan karbohidrat kompleks untuk mempercepat penambahan berat badan massal.'),
        ('L-Glutamine', 250000.00, 'Amino Acids', 'assets/creatine.png', 'Asam amino esensial untuk menjaga daya tahan tubuh dan mempercepat perbaikan sel otot yang rusak.')
      `;
      await pool.query(insertQuery);
      console.log('✅ Dummy data berhasil ditambahkan ke tabel produk.');
    } else {
      console.log('ℹ️ Tabel produk sudah memiliki data, melewati proses insert dummy.');
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error saat inisialisasi database:', error);
    process.exit(1);
  }
};

initDB();
