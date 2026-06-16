const { pool } = require('../config/db');

const getAllProducts = async (filters = {}) => {
  try {
    let query = `
      SELECT p.*, 
             COALESCE(AVG(r.rating), 0) AS average_rating, 
             COUNT(r.id) AS total_reviews
      FROM products p
      LEFT JOIN product_reviews r ON p.id = r.product_id
    `;
    const params = [];
    const conditions = [];

    if (filters.search) {
      conditions.push('(p.name LIKE ? OR p.description LIKE ?)');
      params.push(`%${filters.search}%`, `%${filters.search}%`);
    }

    if (filters.category) {
      conditions.push('p.category = ?');
      params.push(filters.category);
    }

    if (filters.minPrice) {
      conditions.push('p.price >= ?');
      params.push(filters.minPrice);
    }

    if (filters.maxPrice) {
      conditions.push('p.price <= ?');
      params.push(filters.maxPrice);
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' GROUP BY p.id';

    if (filters.sortBy) {
      switch (filters.sortBy) {
        case 'price_asc':
          query += ' ORDER BY p.price ASC';
          break;
        case 'price_desc':
          query += ' ORDER BY p.price DESC';
          break;
        case 'name_asc':
          query += ' ORDER BY p.name ASC';
          break;
        case 'name_desc':
          query += ' ORDER BY p.name DESC';
          break;
        default:
          query += ' ORDER BY p.id DESC';
      }
    } else {
      query += ' ORDER BY p.id DESC';
    }

    const [rows] = await pool.execute(query, params);
    // Parse price dan stock ke integer agar sesuai dengan tipe data di Flutter (int)
    return rows.map(row => ({
      ...row,
      price: parseInt(row.price, 10),
      stock: parseInt(row.stock, 10),
      weight_grams: row.weight_grams ? parseInt(row.weight_grams, 10) : null,
      average_rating: parseFloat(parseFloat(row.average_rating || 0).toFixed(1)),
      total_reviews: parseInt(row.total_reviews || 0)
    }));
  } catch (err) {
    console.error('Error fetching products:', err);
    throw err;
  }
};

module.exports = {
  getAllProducts
};
