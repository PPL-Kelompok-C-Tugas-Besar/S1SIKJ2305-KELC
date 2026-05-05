const { pool } = require('../config/db');

/**
 * GET /checkout/summary
 * Ambil data cart user yang dipilih, join dengan produk,
 * dan hitung subtotal untuk keperluan halaman checkout.
 * Requires: Bearer token (verifyToken middleware)
 */
const getCheckoutSummary = async (req, res) => {
  try {
    const user_id = req.user.id;

    // Join cart dengan produk untuk dapet harga terkini & nama produk
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
      ORDER BY c.id ASC
    `, [user_id]);

    if (rows.length === 0) {
      return res.status(200).json({
        success: true,
        data: {
          items: [],
          subtotal: 0,
          shipping_cost: 0,
          total: 0
        }
      });
    }

    // Format tiap item dan hitung subtotal
    const items = rows.map(row => {
      const price     = parseInt(row.price, 10);
      const quantity  = parseInt(row.quantity, 10);
      const stock     = parseInt(row.stock, 10);

      return {
        cart_id:    row.cart_id,
        product_id: row.product_id,
        name:       row.name,
        image:      row.image_url,
        price,
        quantity,
        stock,
        line_total: price * quantity   // harga per baris
      };
    });

    const subtotal      = items.reduce((acc, item) => acc + item.line_total, 0);
    const shipping_cost = subtotal > 0 ? 50000 : 0; // flat rate Rp 50.000
    const total         = subtotal + shipping_cost;

    return res.status(200).json({
      success: true,
      data: {
        items,
        subtotal,
        shipping_cost,
        total
      }
    });
  } catch (error) {
    console.error('Error in getCheckoutSummary:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server saat mengambil data checkout',
      error: error.message
    });
  }
};

module.exports = { getCheckoutSummary };
