// require('dotenv').config();
// const { pool } = require('./src/config/db');

// const fixTables = async () => {
//   try {
//     const connection = await pool.getConnection();
//     console.log('Fixing orders tables structure...');

//     // Disable FK checks to drop tables safely
//     await connection.query('SET FOREIGN_KEY_CHECKS = 0');

//     console.log('Dropping old tables...');
//     await connection.query('DROP TABLE IF EXISTS defaultdb.order_items');
//     await connection.query('DROP TABLE IF EXISTS defaultdb.orders');

//     console.log('Recreating orders table...');
//     await connection.query(`
//       CREATE TABLE defaultdb.orders (
//         id               INT AUTO_INCREMENT PRIMARY KEY,
//         user_id          VARCHAR(255) NOT NULL,
//         payment_method   VARCHAR(50) NOT NULL,
//         shipping_address TEXT NOT NULL,
//         total_amount     DECIMAL(15, 2) NOT NULL,
//         status           VARCHAR(50) DEFAULT 'Pending',
//         created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
//       )
//     `);

//     console.log('Recreating order_items table...');
//     await connection.query(`
//       CREATE TABLE defaultdb.order_items (
//         id          INT AUTO_INCREMENT PRIMARY KEY,
//         order_id    INT NOT NULL,
//         product_id  INT NOT NULL,
//         quantity    INT NOT NULL,
//         price       DECIMAL(15, 2) NOT NULL,
//         FOREIGN KEY (order_id) REFERENCES defaultdb.orders(id) ON DELETE CASCADE
//       )
//     `);

//     await connection.query('SET FOREIGN_KEY_CHECKS = 1');
//     connection.release();
//     console.log('Tables fixed successfully!');
//     process.exit(0);
//   } catch (err) {
//     console.error('Failed to fix tables:', err.message);
//     process.exit(1);
//   }
// };

// fixTables();
