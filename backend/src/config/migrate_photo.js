const { pool } = require('./db');

async function runPhotoMigration() {
  try {
    const [rows] = await pool.query(`
      SELECT COUNT(*) as count FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = 'photo_url'
    `);
    if (rows[0].count === 0) {
      await pool.query(`ALTER TABLE users ADD COLUMN photo_url LONGTEXT DEFAULT NULL`);
      console.log('✅ Migration: kolom photo_url berhasil ditambahkan ke tabel users.');
    }
  } catch (error) {
    console.error('❌ Migration photo error:', error.message);
  }
}

module.exports = { runPhotoMigration };
