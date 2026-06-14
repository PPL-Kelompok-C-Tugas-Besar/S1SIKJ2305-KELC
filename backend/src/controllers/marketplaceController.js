const { pool } = require('../config/db');

// GET /api/marketplace/products
const getAllProducts = async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT p.*, 
             COALESCE(AVG(r.rating), 0) AS average_rating, 
             COUNT(r.id) AS total_reviews
      FROM products p
      LEFT JOIN product_reviews r ON p.id = r.product_id
      GROUP BY p.id
      ORDER BY p.id DESC
    `);
    
    const products = rows.map(p => ({
      ...p,
      average_rating: parseFloat(parseFloat(p.average_rating).toFixed(1)),
      total_reviews: parseInt(p.total_reviews)
    }));

    return res.status(200).json({ success: true, data: products });
  } catch (err) {
    console.error('Get all products error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

// GET /api/marketplace/products/:id
const getProductById = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.execute(`
      SELECT p.*, 
             COALESCE(AVG(r.rating), 0) AS average_rating, 
             COUNT(r.id) AS total_reviews
      FROM products p
      LEFT JOIN product_reviews r ON p.id = r.product_id
      WHERE p.id = ?
      GROUP BY p.id
    `, [id]);

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Produk tidak ditemukan' });
    }

    const product = {
      ...rows[0],
      average_rating: parseFloat(parseFloat(rows[0].average_rating).toFixed(1)),
      total_reviews: parseInt(rows[0].total_reviews)
    };

    return res.status(200).json({ success: true, data: product });
  } catch (err) {
    console.error('Get product by ID error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

// GET /api/marketplace/products/:id/reviews
const getProductReviews = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.execute(`
      SELECT r.id, r.product_id, r.user_id, r.rating, r.review_text, r.created_at, u.full_name AS user_name
      FROM product_reviews r
      JOIN users u ON r.user_id = u.id
      WHERE r.product_id = ?
      ORDER BY r.created_at DESC
    `, [id]);

    return res.status(200).json({ success: true, data: rows });
  } catch (err) {
    console.error('Get product reviews error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

// POST /api/marketplace/products/:id/reviews
const submitReview = async (req, res) => {
  try {
    const { id } = req.params;
    const { rating, review_text } = req.body;
    const userId = req.user.id;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ success: false, message: 'Rating wajib diisi dan bernilai antara 1 sampai 5' });
    }

    const [[product]] = await pool.execute('SELECT id FROM products WHERE id = ?', [id]);
    if (!product) {
      return res.status(404).json({ success: false, message: 'Produk tidak ditemukan' });
    }

    await pool.execute(`
      INSERT INTO product_reviews (product_id, user_id, rating, review_text)
      VALUES (?, ?, ?, ?)
    `, [id, userId, rating, review_text || null]);

    return res.status(201).json({ success: true, message: 'Ulasan berhasil dikirim' });
  } catch (err) {
    console.error('Submit review error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

// GET /api/marketplace/vouchers
const getAvailableVouchers = async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT * FROM vouchers 
      WHERE is_active = 1 
        AND (start_date IS NULL OR start_date <= CURRENT_TIMESTAMP)
        AND (end_date IS NULL OR end_date >= CURRENT_TIMESTAMP)
      ORDER BY id DESC
    `);
    return res.status(200).json({ success: true, data: rows });
  } catch (err) {
    console.error('Get available vouchers error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

// POST /api/marketplace/orders
const createOrder = async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const { subtotal, voucher_code, payment_method, shipping_address, items } = req.body;
    const userId = req.user.id;

    if (!items || items.length === 0) {
      return res.status(400).json({ success: false, message: 'Keranjang belanja tidak boleh kosong' });
    }

    let calculatedDiscount = 0.00;
    if (voucher_code) {
      const [[voucher]] = await connection.execute(
        `SELECT * FROM vouchers WHERE code = ? AND is_active = 1 
         AND (start_date IS NULL OR start_date <= CURRENT_TIMESTAMP)
         AND (end_date IS NULL OR end_date >= CURRENT_TIMESTAMP)`,
        [voucher_code]
      );

      if (!voucher) {
        await connection.rollback();
        return res.status(400).json({ success: false, message: 'Voucher tidak valid atau sudah tidak aktif' });
      }

      if (parseFloat(subtotal) < parseFloat(voucher.minimum_purchase)) {
        await connection.rollback();
        return res.status(400).json({ success: false, message: `Minimal pembelian Rp${parseFloat(voucher.minimum_purchase).toFixed(0)} tidak terpenuhi` });
      }

      if (voucher.discount_type === 'percentage') {
        calculatedDiscount = parseFloat(subtotal) * (parseFloat(voucher.discount_value) / 100);
        if (voucher.max_discount > 0 && calculatedDiscount > parseFloat(voucher.max_discount)) {
          calculatedDiscount = parseFloat(voucher.max_discount);
        }
      } else if (voucher.discount_type === 'fixed') {
        calculatedDiscount = parseFloat(voucher.discount_value);
      }
    }

    const finalTotal = parseFloat(subtotal) - calculatedDiscount;

    // Generate unique order number
    const todayStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const randomPart = Math.floor(1000 + Math.random() * 9000);
    const orderNumber = `GB-${todayStr}-${randomPart}`;

    // Insert order
    const [orderResult] = await connection.execute(
      `INSERT INTO orders (order_number, user_id, subtotal, discount, voucher_code, total, status, payment_method, shipping_address)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [orderNumber, userId, subtotal, calculatedDiscount, voucher_code || null, finalTotal, 'Paid', payment_method || 'E-Wallet', shipping_address || 'Alamat Default']
    );

    const orderId = orderResult.insertId;

    // Insert order items and update stock
    for (const item of items) {
      // Get current stock
      const [[product]] = await connection.execute('SELECT stock, name FROM products WHERE id = ?', [item.product_id]);
      if (!product) {
        await connection.rollback();
        return res.status(404).json({ success: false, message: `Produk dengan ID ${item.product_id} tidak ditemukan` });
      }

      if (product.stock < item.quantity) {
        await connection.rollback();
        return res.status(400).json({ success: false, message: `Stok produk "${product.name}" tidak mencukupi (Tersisa: ${product.stock})` });
      }

      // Deduct stock
      await connection.execute('UPDATE products SET stock = stock - ? WHERE id = ?', [item.quantity, item.product_id]);

      // Insert order item
      await connection.execute(
        `INSERT INTO order_items (order_id, product_id, product_name, quantity, price)
         VALUES (?, ?, ?, ?, ?)`,
        [orderId, item.product_id, item.product_name, item.quantity, item.price]
      );
    }

    await connection.commit();
    return res.status(201).json({
      success: true,
      message: 'Transaksi berhasil dibuat',
      data: {
        id: orderId,
        order_number: orderNumber,
        total: finalTotal,
      }
    });
  } catch (err) {
    await connection.rollback();
    console.error('Create order error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  } finally {
    connection.release();
  }
};

// GET /api/marketplace/orders
const getUserOrders = async (req, res) => {
  try {
    const userId = req.user.id;
    const [rows] = await pool.execute(
      'SELECT * FROM orders WHERE user_id = ? ORDER BY date DESC',
      [userId]
    );
    return res.status(200).json({ success: true, data: rows });
  } catch (err) {
    console.error('Get user orders error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

// GET /api/marketplace/orders/:id
const getOrderDetails = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Fetch order details
    const [[order]] = await pool.execute(
      'SELECT * FROM orders WHERE id = ? AND user_id = ?',
      [id, userId]
    );

    if (!order) {
      return res.status(404).json({ success: false, message: 'Transaksi tidak ditemukan' });
    }

    // Fetch order items
    const [items] = await pool.execute(
      'SELECT * FROM order_items WHERE order_id = ?',
      [id]
    );

    order.items = items;

    return res.status(200).json({ success: true, data: order });
  } catch (err) {
    console.error('Get order details error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

// GET /api/marketplace/wishlist
const getWishlist = async (req, res) => {
  try {
    const userId = req.user.id;
    const [rows] = await pool.execute(`
      SELECT p.*,
             COALESCE(AVG(r.rating), 0) AS average_rating, 
             COUNT(r.id) AS total_reviews
      FROM wishlists w
      JOIN products p ON w.product_id = p.id
      LEFT JOIN product_reviews r ON p.id = r.product_id
      WHERE w.user_id = ?
      GROUP BY p.id
      ORDER BY w.created_at DESC
    `, [userId]);

    const products = rows.map(p => ({
      ...p,
      average_rating: parseFloat(parseFloat(p.average_rating).toFixed(1)),
      total_reviews: parseInt(p.total_reviews)
    }));

    return res.status(200).json({ success: true, data: products });
  } catch (err) {
    console.error('Get wishlist error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

// POST /api/marketplace/wishlist
const addToWishlist = async (req, res) => {
  try {
    const { product_id } = req.body;
    const userId = req.user.id;

    if (!product_id) {
      return res.status(400).json({ success: false, message: 'product_id wajib diisi' });
    }

    await pool.execute(`
      INSERT IGNORE INTO wishlists (user_id, product_id)
      VALUES (?, ?)
    `, [userId, product_id]);

    return res.status(201).json({ success: true, message: 'Produk berhasil ditambahkan ke wishlist' });
  } catch (err) {
    console.error('Add to wishlist error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

// DELETE /api/marketplace/wishlist/:productId
const removeFromWishlist = async (req, res) => {
  try {
    const { productId } = req.params;
    const userId = req.user.id;

    await pool.execute(`
      DELETE FROM wishlists WHERE user_id = ? AND product_id = ?
    `, [userId, productId]);

    return res.status(200).json({ success: true, message: 'Produk berhasil dihapus dari wishlist' });
  } catch (err) {
    console.error('Remove from wishlist error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

module.exports = {
  getAllProducts,
  getProductById,
  getProductReviews,
  submitReview,
  getAvailableVouchers,
  createOrder,
  getUserOrders,
  getOrderDetails,
  getWishlist,
  addToWishlist,
  removeFromWishlist,
};
