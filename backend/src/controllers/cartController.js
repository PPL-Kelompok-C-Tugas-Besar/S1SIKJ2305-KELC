const { pool } = require('../config/db');

/**
 * Menangani request POST /cart
 * Body: product_id, quantity
 */
const addToCart = async (req, res) => {
  try {
    const user_id = req.user.id; // Diambil dari token
    const { product_id, quantity } = req.body;

    if (!product_id || !quantity) {
      return res.status(400).json({ success: false, message: 'product_id dan quantity wajib diisi' });
    }

    // Cek apakah produk sudah ada di cart untuk user ini
    const [existing] = await pool.execute(
      'SELECT id, quantity FROM defaultdb.carts WHERE user_id = ? AND product_id = ?',
      [user_id, product_id]
    );

    if (existing.length > 0) {
      // Update quantity jika sudah ada
      const newQuantity = existing[0].quantity + quantity;
      await pool.execute(
        'UPDATE defaultdb.carts SET quantity = ? WHERE id = ?',
        [newQuantity, existing[0].id]
      );
    } else {
      // Insert baru
      await pool.execute(
        'INSERT INTO defaultdb.carts (user_id, product_id, quantity) VALUES (?, ?, ?)',
        [user_id, product_id, quantity]
      );
    }

    return res.status(201).json({
      success: true,
      message: 'Berhasil menambahkan produk ke cart'
    });
  } catch (error) {
    console.error('Error in addToCart:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server saat menambahkan ke cart',
      error: error.message
    });
  }
};

module.exports = {
  addToCart
};
