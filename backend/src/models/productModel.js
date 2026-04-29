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
      name: 'Optimum Whey Protein',
      description: 'Premium quality whey protein supplement designed to help you crush your workouts and build lean muscle mass.',
      price: 850000,
      stock: 50,
      image_url: 'assets/whey.png',
      category: 'Protein'
    },
    {
      id: 2,
      name: 'Creatine Monohydrate',
      description: 'Pure creatine monohydrate to boost strength, power, and muscle volume during intense workouts.',
      price: 350000,
      stock: 120,
      image_url: 'assets/creatine.png',
      category: 'Performance'
    },
    {
      id: 3,
      name: 'Pre-Workout Blast',
      description: 'Explosive energy and focus for your toughest gym sessions. Contains caffeine, beta-alanine, and citrulline.',
      price: 450000,
      stock: 75,
      image_url: 'assets/whey.png',
      category: 'Pre-Workout'
    },
    {
      id: 4,
      name: 'BCAA Plus',
      description: 'Branched-Chain Amino Acids to support muscle recovery and reduce fatigue during long workouts.',
      price: 300000,
      stock: 100,
      image_url: 'assets/creatine.png',
      category: 'Recovery'
    },
    {
      id: 5,
      name: 'Mass Gainer Extreme',
      description: 'High-calorie mass gainer packed with protein and complex carbs for serious bulking.',
      price: 950000,
      stock: 30,
      image_url: 'assets/whey.png',
      category: 'Weight Gainer'
    },
    {
      id: 6,
      name: 'Pure Glutamine',
      description: 'L-Glutamine powder to support gut health and rapid muscle tissue repair.',
      price: 250000,
      stock: 85,
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
