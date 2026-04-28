const { pool } = require('../config/db');

// @desc    Search or get all products
// @route   GET /api/produk/search?q=keyword
// @access  Public
const searchProducts = async (req, res) => {
  try {
    const keyword = req.query.q || '';
    
    // Search in 'nama', 'kategori', or 'deskripsi'
    const query = `
      SELECT * FROM produk 
      WHERE nama LIKE ? 
         OR kategori LIKE ? 
         OR deskripsi LIKE ?
    `;
    const searchPattern = `%${keyword}%`;
    const [rows] = await pool.query(query, [searchPattern, searchPattern, searchPattern]);
    
    res.status(200).json({
      success: true,
      count: rows.length,
      data: rows
    });
  } catch (error) {
    console.error('Error in searchProducts:', error.message);
    res.status(500).json({
      success: false,
      message: 'Server error saat mencari produk'
    });
  }
};

module.exports = {
  searchProducts
};
