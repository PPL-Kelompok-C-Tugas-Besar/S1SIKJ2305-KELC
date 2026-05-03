require('dotenv').config();
const { pool } = require('./src/config/db');

async function check() {
  try {
    const [rows] = await pool.query('SHOW TABLES');
    console.log('defaultdb tables:', rows);
    
    // check gymbro_db
    const [rows2] = await pool.query('SHOW TABLES FROM gymbro_db');
    console.log('gymbro_db tables:', rows2);

    for (let r of rows) {
      let tname = Object.values(r)[0];
      if (tname.toLowerCase().includes('cart')) {
        const [desc] = await pool.query(`DESCRIBE ${tname}`);
        console.log(`Table defaultdb.${tname}:`, desc);
      }
    }
    
    for (let r of rows2) {
      let tname = Object.values(r)[0];
      if (tname.toLowerCase().includes('cart')) {
        const [desc] = await pool.query(`DESCRIBE gymbro_db.${tname}`);
        console.log(`Table gymbro_db.${tname}:`, desc);
      }
    }

  } catch(e) {
    console.error(e);
  } finally {
    process.exit(0);
  }
}
check();
