const { pool } = require('../config/db');

const getAllProducts = async (filters = {}) => {
  try {
    let query = 'SELECT * FROM defaultdb.products';
    const params = [];
    const conditions = [];

    if (filters.search) {
      conditions.push('(name LIKE ? OR description LIKE ?)');
      params.push(`%${filters.search}%`, `%${filters.search}%`);
    }

    if (filters.category) {
      conditions.push('category = ?');
      params.push(filters.category);
    }

    if (filters.minPrice) {
      conditions.push('price >= ?');
      params.push(filters.minPrice);
    }

    if (filters.maxPrice) {
      conditions.push('price <= ?');
      params.push(filters.maxPrice);
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    if (filters.sortBy) {
      switch (filters.sortBy) {
        case 'price_asc':
          query += ' ORDER BY price ASC';
          break;
        case 'price_desc':
          query += ' ORDER BY price DESC';
          break;
        case 'name_asc':
          query += ' ORDER BY name ASC';
          break;
        case 'name_desc':
          query += ' ORDER BY name DESC';
          break;
        default:
          query += ' ORDER BY id DESC';
      }
    } else {
      query += ' ORDER BY id DESC';
    }

    const [rows] = await pool.execute(query, params);
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
