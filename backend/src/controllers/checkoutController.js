const { pool } = require('../config/db');

/**
 * GET /checkout/summary
 * Ambil data cart user, join produk, hitung subtotal.
 * Requires: Authorization: Bearer <token>
 */
const getCheckoutSummary = async (req, res) => {
  try {
    const user_id = req.user.id;

    // Join cart dengan tabel produk untuk ambil harga, nama, stok terkini
    const [rows] = await pool.execute(`
      SELECT
        c.id          AS cart_id,
        c.quantity,
        p.id          AS product_id,
        p.name,
        p.price,
        p.image_url,
        p.stock
      FROM defaultdb.carts c
      JOIN defaultdb.products p ON c.product_id = p.id
      WHERE c.user_id = ?
    `, [user_id]);

    if (rows.length === 0) {
      return res.status(200).json({
        success: true,
        data: {
          items: [],
          subtotal: 0,
          shipping_cost: 0,
          total: 0,
        },
      });
    }

    // Susun list item dan hitung subtotal
    let subtotal = 0;
    const items = rows.map(row => {
      const price    = parseInt(row.price, 10);
      const quantity = parseInt(row.quantity, 10);
      const itemTotal = price * quantity;
      subtotal += itemTotal;

      return {
        cart_id:    row.cart_id,
        product_id: row.product_id,
        name:       row.name,
        image:      row.image_url,
        price,
        quantity,
        stock:      parseInt(row.stock, 10),
        item_total: itemTotal,
      };
    });

    // Flat-rate shipping Rp 50.000 jika ada item, 0 jika kosong
    const shipping_cost = subtotal > 0 ? 50000 : 0;
    const total = subtotal + shipping_cost;

    return res.status(200).json({
      success: true,
      data: {
        items,
        subtotal,
        shipping_cost,
        total,
      },
    });
  } catch (error) {
    console.error('Error in getCheckoutSummary:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server saat mengambil data checkout',
      error: error.message,
    });
  }
};

/**
 * POST /checkout/order
 * Simpan pesanan ke database, hapus dari cart, dan update stok.
 */
const placeOrder = async (req, res) => {
  const connection = await pool.getConnection();
  try {
    const user_id = req.user.id;
    const { items, payment_method, shipping_address, total } = req.body;

    if (!items || items.length === 0) {
      return res.status(400).json({ success: false, message: 'Item pesanan tidak boleh kosong' });
    }

    await connection.beginTransaction();

    // 1. Simpan ke tabel orders
    const [orderResult] = await connection.execute(
      'INSERT INTO defaultdb.orders (user_id, payment_method, shipping_address, total_amount, status) VALUES (?, ?, ?, ?, ?)',
      [user_id, payment_method, shipping_address, total, 'Pending']
    );
    const orderId = orderResult.insertId;

    // 2. Loop items untuk order_items, update stock, dan hapus dari cart
    for (const item of items) {
      const { product_id, quantity, price, cart_id } = item;

      // a. Simpan ke order_items
      await connection.execute(
        'INSERT INTO defaultdb.order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)',
        [orderId, product_id, quantity, price]
      );

      // b. Update stok produk
      await connection.execute(
        'UPDATE defaultdb.products SET stock = stock - ? WHERE id = ?',
        [quantity, product_id]
      );

      // c. Hapus dari cart jika ada cart_id
      if (cart_id) {
        await connection.execute(
          'DELETE FROM defaultdb.carts WHERE id = ? AND user_id = ?',
          [cart_id, user_id]
        );
      }
    }

    await connection.commit();
    return res.status(201).json({
      success: true,
      message: 'Pesanan berhasil dibuat',
      order_id: orderId
    });

  } catch (error) {
    await connection.rollback();
    console.error('Error in placeOrder:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal memproses pesanan',
      error: error.message
    });
  } finally {
    connection.release();
  }
};

module.exports = { getCheckoutSummary, placeOrder };
