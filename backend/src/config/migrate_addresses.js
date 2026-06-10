const { pool } = require('./db');

async function runAddressesMigration() {
  try {
    // 1. Create table with is_default column if it doesn't exist yet (matching the existing db addresses schema)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS addresses (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        label VARCHAR(50) NULL,
        recipient_name VARCHAR(255) NOT NULL,
        phone VARCHAR(20) NOT NULL,
        complete_address TEXT NOT NULL,
        is_default TINYINT(1) DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_addresses_user_id (user_id)
      )
    `);

    console.log('✅ Migration: addresses table verified (exists and is ready).');
  } catch (error) {
    console.error('❌ Migration addresses error:', error.message);
  }
}

module.exports = { runAddressesMigration };
