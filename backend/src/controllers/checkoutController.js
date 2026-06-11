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
      FROM carts c
      JOIN products p ON c.product_id = p.id
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
      'INSERT INTO orders (user_id, payment_method, shipping_address, total_amount, status) VALUES (?, ?, ?, ?, ?)',
      [user_id, payment_method, shipping_address, total, 'Pending']
    );
    const orderId = orderResult.insertId;

    // 1b. Simpan status awal ke order_tracking
    await connection.execute(
      'INSERT INTO order_tracking (order_id, status, description) VALUES (?, ?, ?)',
      [orderId, 'Pending', 'Pesanan berhasil dibuat dan menunggu pembayaran.']
    );

    // 2. Loop items untuk order_items, update stock, dan hapus dari cart
    for (const item of items) {
      const { product_id, quantity, price, cart_id } = item;

      // a. Simpan ke order_items
      await connection.execute(
        'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)',
        [orderId, product_id, quantity, price]
      );

      // b. Update stok produk
      await connection.execute(
        'UPDATE products SET stock = stock - ? WHERE id = ?',
        [quantity, product_id]
      );

      // c. Hapus dari cart jika ada cart_id
      if (cart_id) {
        await connection.execute(
          'DELETE FROM carts WHERE id = ? AND user_id = ?',
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

/**
 * GET /checkout/orders
 * Ambil semua order milik user yang terotentikasi.
 */
const getUserOrders = async (req, res) => {
  try {
    const userId = req.user.id;

    // Ambil data orders join order_items & products
    const [rows] = await pool.execute(`
      SELECT
        o.id AS order_id,
        o.payment_method,
        o.shipping_address,
        o.total_amount,
        o.status AS order_status,
        o.created_at AS order_date,
        oi.id AS item_id,
        oi.product_id,
        oi.quantity,
        oi.price AS item_price,
        p.name AS product_name,
        p.image_url AS product_image
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      LEFT JOIN products p ON oi.product_id = p.id
      WHERE o.user_id = ?
      ORDER BY o.created_at DESC, o.id DESC
    `, [userId]);

    const formatDateIndonesian = (dateObj) => {
      if (!dateObj) return '';
      const date = new Date(dateObj);
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      const day = date.getDate();
      const month = months[date.getMonth()];
      const year = date.getFullYear();
      const hours = String(date.getHours()).padStart(2, '0');
      const minutes = String(date.getMinutes()).padStart(2, '0');
      return `${day} ${month} ${year}, ${hours}:${minutes}`;
    };

    const ordersMap = new Map();
    for (const row of rows) {
      if (!ordersMap.has(row.order_id)) {
        ordersMap.set(row.order_id, {
          id: `INV/${row.order_id.toString().padStart(8, '0')}`,
          order_id_raw: row.order_id,
          date: formatDateIndonesian(row.order_date),
          status: row.order_status,
          payment_method: row.payment_method,
          shipping_address: row.shipping_address,
          total_amount: parseFloat(row.total_amount),
          shipping_cost: 50000,
          items: [],
          tracking: []
        });
      }

      if (row.item_id) {
        ordersMap.get(row.order_id).items.push({
          product_id: row.product_id,
          name: row.product_name || 'Produk Tidak Dikenal',
          image: row.product_image || 'assets/whey.png',
          quantity: parseInt(row.quantity, 10),
          price: parseFloat(row.item_price)
        });
      }
    }

    const orderIds = Array.from(ordersMap.keys());
    if (orderIds.length > 0) {
      const placeholders = orderIds.map(() => '?').join(',');
      const [trackingRows] = await pool.execute(`
        SELECT id, order_id, status, description, created_at
        FROM order_tracking
        WHERE order_id IN (${placeholders})
        ORDER BY created_at ASC, id ASC
      `, orderIds);

      for (const tRow of trackingRows) {
        if (ordersMap.has(tRow.order_id)) {
          ordersMap.get(tRow.order_id).tracking.push({
            id: tRow.id,
            status: tRow.status,
            description: tRow.description,
            created_at: formatDateIndonesian(tRow.created_at)
          });
        }
      }
    }

    const ordersList = Array.from(ordersMap.values());

    return res.status(200).json({
      success: true,
      data: ordersList
    });
  } catch (error) {
    console.error('Error in getUserOrders:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server saat mengambil riwayat transaksi',
      error: error.message
    });
  }
};

module.exports = { getCheckoutSummary, placeOrder, getUserOrders };
