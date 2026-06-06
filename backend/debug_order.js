// require('dotenv').config();
// const { pool } = require('./src/config/db');

// async function testPlaceOrder() {
//   const connection = await pool.getConnection();
//   try {
//     const user_id = 'test_user'; // Need a valid user_id if FK exists, but I didn't add FK to users
//     const body = {
//       items: [
//         { product_id: 1, quantity: 1, price: 100, cart_id: null }
//       ],
//       payment_method: 'QRIS',
//       shipping_address: 'Test Address',
//       total: 100
//     };

//     const { items, payment_method, shipping_address, total } = body;

//     await connection.beginTransaction();

//     console.log('Inserting into orders...');
//     const [orderResult] = await connection.execute(
//       'INSERT INTO defaultdb.orders (user_id, payment_method, shipping_address, total_amount, status) VALUES (?, ?, ?, ?, ?)',
//       [user_id, payment_method, shipping_address, total, 'Pending']
//     );
//     const orderId = orderResult.insertId;
//     console.log('Order ID:', orderId);

//     for (const item of items) {
//       const { product_id, quantity, price, cart_id } = item;
//       console.log('Inserting into order_items for product:', product_id);
//       await connection.execute(
//         'INSERT INTO defaultdb.order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)',
//         [orderId, product_id, quantity, price]
//       );

//       console.log('Updating stock for product:', product_id);
//       await connection.execute(
//         'UPDATE defaultdb.products SET stock = stock - ? WHERE id = ?',
//         [quantity, product_id]
//       );
//     }

//     await connection.commit();
//     console.log('Success!');
//   } catch (error) {
//     await connection.rollback();
//     console.error('FAILED:', error.message);
//   } finally {
//     connection.release();
//     process.exit();
//   }
// }

// testPlaceOrder();
