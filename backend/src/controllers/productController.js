const productModel = require('../models/productModel');

/**
 * Menangani request GET /products
 */
const getProducts = async (req, res) => {
  try {
    // Memanggil model untuk mendapatkan data (dummy atau DB)
    const products = await productModel.getAllProducts();
    
    // Mengembalikan response sukses
    res.status(200).json({
      success: true,
      message: 'Berhasil mengambil daftar produk',
      data: products
    });
  } catch (error) {
    console.error('Error in getProducts:', error);
    
    // Menangani error (500 Internal Server Error)
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server saat mengambil data produk',
      error: error.message
    });
  }
};

module.exports = {
  getProducts
};
