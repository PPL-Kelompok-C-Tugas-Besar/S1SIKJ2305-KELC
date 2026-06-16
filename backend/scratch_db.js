const mysql = require('mysql2/promise');
require('dotenv').config();

async function run() {
  try {
    const pool = mysql.createPool({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      port: process.env.DB_PORT
    });
    
    const [rows] = await pool.query('SELECT * FROM vouchers');
    console.log(rows);
    process.exit(0);
  } catch(e) {
    console.error(e);
  }
}
run();
