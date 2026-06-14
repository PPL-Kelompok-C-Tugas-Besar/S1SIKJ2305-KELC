const { pool } = require('./db');

async function migrateHeight() {
  try {
    await pool.execute(`
      ALTER TABLE users
      ADD COLUMN IF NOT EXISTS height FLOAT DEFAULT NULL
    `);
    console.log('Migration success: kolom height berhasil ditambahkan ke tabel users');
  } catch (err) {
    if (err.code === 'ER_DUP_FIELDNAME') {
      console.log('Kolom height sudah ada, skip migration');
    } else {
      console.error('Migration error:', err);
      throw err;
    }
  } finally {
    process.exit(0);
  }
}

migrateHeight();
