const { pool } = require('./db');

async function runMigration() {
    try {
        await pool.query(`
            CREATE TABLE IF NOT EXISTS workout_history (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id VARCHAR(255) NOT NULL,
                workout_name VARCHAR(255) NOT NULL,
                duration_minutes INT NOT NULL,
                calories_burned INT NOT NULL,
                date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES USERS(id) ON DELETE CASCADE
            )
        `);
        console.log("✅ Migration: workout_history table created successfully.");
    } catch (error) {
        console.error("❌ Migration error:", error.message);
    }
}

module.exports = { runMigration };
