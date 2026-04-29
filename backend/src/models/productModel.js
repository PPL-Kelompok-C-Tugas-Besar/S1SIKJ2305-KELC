// File: src/models/productModel.js
// Nanti kalo database udah siap, import konfigurasi db di sini
// const db = require('../config/db');

/**
 * Mengambil semua produk dari database.
 * Saat ini menggunakan data dummy karena tabel belum tersedia.
 * 
 * TODO: Saat database siap, cukup ubah isi fungsi ini menjadi query ke database.
 * Contoh: 
 * const [rows] = await db.query('SELECT * FROM products');
 * return rows;
 */
const getAllProducts = async () => {
  // Dummy data sesuai dengan skema tabel products (Katalog)
  const dummyProducts = [
    {
      id: 1,
      name: 'gacor Whey Protein',
      price: 10000,
      stock: 10,
      image_url: 'assets/whey.png',
      category: 'Protein'
    },
    {
      id: 2,
      name: 'Creatine Monohydrate',
      price: 350000,
      stock: 12,
      image_url: 'assets/creatine.png',
      category: 'Performance'
    },
    {
      id: 3,
      name: 'Pre-Workout Blast',
      price: 450000,
      stock: 7,
      image_url: 'assets/whey.png',
      category: 'Pre-Workout'
    },
    {
      id: 4,
      name: 'BCAA Plus',
      price: 300000,
      stock: 10,
      image_url: 'assets/creatine.png',
      category: 'Recovery'
    },
    {
      id: 5,
      name: 'Mass Gainer Extreme',
      price: 950000,
      stock: 7,
      image_url: 'assets/whey.png',
      category: 'Weight Gainer'
    },
    {
      id: 6,
      name: 'Pure Glutamine',
      price: 250000,
      stock: 8,
      image_url: 'assets/creatine.png',
      category: 'Recovery'
    }
  ];

  // Simulasi delay database ringan
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(dummyProducts);
    }, 200);
  });
};

module.exports = {
  getAllProducts
};
