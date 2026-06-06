// require('dotenv').config();
// const { pool } = require('./src/config/db');

// const migrateOrders = async () => {
//   try {
//     const connection = await pool.getConnection();
//     console.log('Migrating orders tables...');

//     // 1. Create orders table
//     await connection.query(`
//       CREATE TABLE IF NOT EXISTS defaultdb.orders (
//         id               INT AUTO_INCREMENT PRIMARY KEY,
//         user_id          VARCHAR(255) NOT NULL,
//         payment_method   VARCHAR(50) NOT NULL,
//         shipping_address TEXT NOT NULL,
//         total_amount     DECIMAL(15, 2) NOT NULL,
//         status           VARCHAR(50) DEFAULT 'Pending',
//         created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
//       )
//     `);
//     console.log('Table "orders" ready.');

//     // 2. Create order_items table
//     await connection.query(`
//       CREATE TABLE IF NOT EXISTS defaultdb.order_items (
//         id          INT AUTO_INCREMENT PRIMARY KEY,
//         order_id    INT NOT NULL,
//         product_id  INT NOT NULL,
//         quantity    INT NOT NULL,
//         price       DECIMAL(15, 2) NOT NULL,
//         FOREIGN KEY (order_id) REFERENCES defaultdb.orders(id) ON DELETE CASCADE
//       )
//     `);
//     console.log('Table "order_items" ready.');

//     connection.release();
//     console.log('Migration completed successfully.');
//     process.exit(0);
//   } catch (err) {
//     console.error('Migration failed:', err.message);
//     process.exit(1);
//   }
// };

// migrateOrders();
