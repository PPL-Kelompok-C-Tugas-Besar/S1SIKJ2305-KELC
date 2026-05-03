const { pool } = require('../config/db');

const getAllProducts = async () => {
  try {
    const [rows] = await pool.execute('SELECT * FROM defaultdb.products');
    // Parse price dan stock ke integer agar sesuai dengan tipe data di Flutter (int)
    return rows.map(row => ({
      ...row,
      price: parseInt(row.price, 10),
      stock: parseInt(row.stock, 10),
      weight_grams: row.weight_grams ? parseInt(row.weight_grams, 10) : null
    }));
  } catch (err) {
    console.error('Error fetching products:', err);
    throw err;
  }
};

module.exports = {
  getAllProducts
};
