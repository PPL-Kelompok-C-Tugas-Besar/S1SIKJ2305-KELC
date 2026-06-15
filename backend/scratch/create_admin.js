
require('dotenv').config();
const { pool } = require('../src/config/db');
const bcrypt = require('bcrypt');
const crypto = require('crypto');
async function createAdmin() {
  try {
    const email = 'admin@gymbro.com';
    const password = 'admin123';
    
    const [existing] = await pool.execute('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      console.log('Admin user already exists:', email);
      const hashedPassword = await bcrypt.hash(password, 10);
      // Update role and password just in case
      await pool.execute('UPDATE users SET role = \'admin\', password = ? WHERE email = ?', [hashedPassword, email]);
      console.log('Role and password updated for:', email);
    } else {
      const hashedPassword = await bcrypt.hash(password, 10);
      const userId = crypto.randomUUID();
      await pool.execute(
        'INSERT INTO users (id, full_name, email, password, role) VALUES (?, ?, ?, ?, ?)',
        [userId, 'Gymbro Admin', email, hashedPassword, 'admin']
      );
      console.log('Admin user created successfully!');
      console.log('Email:', email);
      console.log('Password:', password);
    }
    process.exit(0);
  } catch (err) {
    console.error('Error creating admin:', err);
    process.exit(1);
  }
}

createAdmin();
