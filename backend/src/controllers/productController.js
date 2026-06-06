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

const validateCheckout = async (req, res) => {
  try {
    const { items } = req.body;
    
    if (!items || !Array.isArray(items)) {
      return res.status(400).json({ success: false, message: 'Invalid items data' });
    }

    const products = await productModel.getAllProducts();
    
    for (const item of items) {
      const product = products.find(p => p.id == item.id);
      if (product) {
        if (item.quantity > product.stock) {
          return res.status(400).json({ 
            success: false, 
            message: 'maaf, pembelian melewati stock' 
          });
        }
      }
    }

    return res.status(200).json({
      success: true,
      message: 'Checkout valid'
    });
  } catch (error) {
    console.error('Error in validateCheckout:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server saat validasi',
      error: error.message
    });
  }
};

module.exports = {
  getProducts,
  validateCheckout
};
