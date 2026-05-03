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

    // 1. Ambil stok produk saat ini dari gudang (database)
    const [products] = await pool.execute(
      'SELECT stock FROM defaultdb.products WHERE id = ?',
      [product_id]
    );

    if (products.length === 0) {
      return res.status(404).json({ success: false, message: 'Produk tidak ditemukan' });
    }

    const availableStock = parseInt(products[0].stock, 10);

    // 2. Cek apakah produk sudah ada di cart untuk user ini
    const [existing] = await pool.execute(
      'SELECT id, quantity FROM defaultdb.carts WHERE user_id = ? AND product_id = ?',
      [user_id, product_id]
    );

    let currentQuantityInCart = 0;
    if (existing.length > 0) {
      currentQuantityInCart = parseInt(existing[0].quantity, 10);
    }

    const totalQuantity = currentQuantityInCart + quantity;

    // 3. Validasi: Apakah total yang diminta melebihi stok yang ada?
    if (totalQuantity > availableStock) {
      return res.status(400).json({ 
        success: false, 
        message: `Maaf, stok tidak mencukupi. Sisa stok: ${availableStock}. Di keranjang Anda sudah ada: ${currentQuantityInCart}.` 
      });
    }

    // 4. Jika stok aman, lanjutkan insert atau update
    if (existing.length > 0) {
      // Update quantity
      await pool.execute(
        'UPDATE defaultdb.carts SET quantity = ? WHERE id = ?',
        [totalQuantity, existing[0].id]
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

const getCart = async (req, res) => {
  try {
    const user_id = req.user.id;
    const [rows] = await pool.execute(`
      SELECT c.id as cart_id, c.quantity, p.id as product_id, p.name, p.price, p.image_url, p.stock
      FROM defaultdb.carts c
      JOIN defaultdb.products p ON c.product_id = p.id
      WHERE c.user_id = ?
    `, [user_id]);

    const formattedData = rows.map(row => ({
      id: row.cart_id.toString(), // frontend expects string id for cart item
      product_id: row.product_id,
      name: row.name,
      variant: 'Standard',
      price: parseInt(row.price, 10),
      quantity: parseInt(row.quantity, 10),
      image: row.image_url,
      stock: parseInt(row.stock, 10),
      selected: true
    }));

    return res.status(200).json({ success: true, data: formattedData });
  } catch (error) {
    console.error('Error fetching cart:', error);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

const updateCartItem = async (req, res) => {
  try {
    const { id } = req.params;
    const { quantity } = req.body;
    const user_id = req.user.id;

    // Check ownership
    const [existing] = await pool.execute('SELECT * FROM defaultdb.carts WHERE id = ? AND user_id = ?', [id, user_id]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: 'Item tidak ditemukan' });
    }

    // Check stock
    const [product] = await pool.execute('SELECT stock FROM defaultdb.products WHERE id = ?', [existing[0].product_id]);
    const availableStock = product.length > 0 ? parseInt(product[0].stock, 10) : 0;
    if (quantity > availableStock) {
      return res.status(400).json({ success: false, message: `Stok hanya sisa ${availableStock}` });
    }

    await pool.execute('UPDATE defaultdb.carts SET quantity = ? WHERE id = ?', [quantity, id]);
    return res.status(200).json({ success: true, message: 'Berhasil diupdate' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

const removeCartItem = async (req, res) => {
  try {
    const { id } = req.params;
    const user_id = req.user.id;
    await pool.execute('DELETE FROM defaultdb.carts WHERE id = ? AND user_id = ?', [id, user_id]);
    return res.status(200).json({ success: true, message: 'Item dihapus' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

module.exports = {
  addToCart,
  getCart,
  updateCartItem,
  removeCartItem
};
