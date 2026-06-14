require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { pool } = require('./db');

// ─────────────────────────────────────────────────────────────────────────────
// Migration: migrate_users_calorie_target.js
// PBI     : Rekomendasi Target Kalori Harian
// Subtask : [Database] Tambahkan field fisik & target kalori di tabel users
// ─────────────────────────────────────────────────────────────────────────────

async function runUsersCalorieMigration() {
  try {
    // ─── Cek kolom yang sudah ada ──
    const [columns] = await pool.query(`
      SELECT COLUMN_NAME
      FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME   = 'users'
    `);

    const existingColumns = columns.map(c => c.COLUMN_NAME);

    const newColumns = [
      { name: 'height', def: 'FLOAT DEFAULT NULL' },
      { name: 'age', def: 'INT DEFAULT NULL' },
      { name: 'activity_level', def: 'VARCHAR(50) DEFAULT NULL' },
      { name: 'diet_goal', def: 'VARCHAR(50) DEFAULT NULL' },
      { name: 'daily_calorie_target', def: 'INT DEFAULT NULL' },
      { name: 'weekly_workout_goal', def: 'INT DEFAULT 3' }
    ];

    let altered = false;

    for (const col of newColumns) {
      if (!existingColumns.includes(col.name)) {
        await pool.query(`ALTER TABLE users ADD COLUMN ${col.name} ${col.def}`);
        console.log(`✅ Migration: kolom ${col.name} berhasil ditambahkan ke tabel users.`);
        altered = true;
      } else {
        console.log(`ℹ️  Migration: kolom ${col.name} sudah ada, lewati.`);
      }
    }

    if (!altered) {
      console.log('ℹ️  Migration: Semua kolom yang dibutuhkan di tabel users sudah tersedia.');
    }

  } catch (error) {
    console.error('❌ Migration error (users_calorie_target):', error.message);
    throw error;
  }
}

module.exports = { runUsersCalorieMigration };
