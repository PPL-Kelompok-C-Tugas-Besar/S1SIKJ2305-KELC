require('dotenv').config();
const { pool } = require('../src/config/db');

async function check() {
  try {
    const [tables] = await pool.query('SHOW TABLES');
    console.log('Tables in database:', tables.map(t => Object.values(t)[0]));
    
    for (let table of ['orders', 'order_items', 'vouchers']) {
      try {
        const [columns] = await pool.query(`DESCRIBE ${table}`);
        console.log(`\nColumns in ${table}:`);
        columns.forEach(c => {
          console.log(`- ${c.Field}: ${c.Type} (${c.Null}, ${c.Key}, ${c.Default})`);
        });
      } catch (e) {
        console.log(`\nTable ${table} describe failed:`, e.message);
      }
    }
    
    process.exit(0);
  } catch (err) {
    console.error('Error checking tables:', err);
    process.exit(1);
  }
}

check();
