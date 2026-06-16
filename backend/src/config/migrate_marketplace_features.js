const { pool } = require('./db');

async function runMarketplaceFeaturesMigration() {
    try {
        // 1. Create vouchers table
        await pool.query(`
            CREATE TABLE IF NOT EXISTS vouchers (
                id INT AUTO_INCREMENT PRIMARY KEY,
                code VARCHAR(50) NOT NULL UNIQUE,
                name VARCHAR(255) NOT NULL,
                description TEXT,
                discount_type VARCHAR(50) NOT NULL,
                discount_value DECIMAL(15, 2) NOT NULL,
                minimum_purchase DECIMAL(15, 2) DEFAULT 0.00,
                max_discount DECIMAL(15, 2) DEFAULT 0.00,
                start_date TIMESTAMP NULL,
                end_date TIMESTAMP NULL,
                is_active BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);
        console.log("✅ Migration: vouchers table ready.");
 
        // 2. Create orders table
        await pool.query(`
            CREATE TABLE IF NOT EXISTS orders (
                id INT AUTO_INCREMENT PRIMARY KEY,
                order_number VARCHAR(100) NOT NULL UNIQUE,
                user_id VARCHAR(255) NOT NULL,
                date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                subtotal DECIMAL(15, 2) NOT NULL,
                discount DECIMAL(15, 2) DEFAULT 0.00,
                voucher_code VARCHAR(50) NULL,
                total DECIMAL(15, 2) NOT NULL,
                status VARCHAR(50) DEFAULT 'Pending',
                payment_method VARCHAR(50) NULL,
                shipping_address TEXT NULL,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            )
        `);
        console.log("✅ Migration: orders table ready.");
 
        // 3. Create order_items table
        await pool.query(`
            CREATE TABLE IF NOT EXISTS order_items (
                id INT AUTO_INCREMENT PRIMARY KEY,
                order_id INT NOT NULL,
                product_id INT NOT NULL,
                product_name VARCHAR(255) NOT NULL,
                quantity INT NOT NULL,
                price DECIMAL(15, 2) NOT NULL,
                FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
                FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
            )
        `);
        console.log("✅ Migration: order_items table ready.");

        // 3b. Create order_tracking table
        await pool.query(`
            CREATE TABLE IF NOT EXISTS order_tracking (
                id INT AUTO_INCREMENT PRIMARY KEY,
                order_id INT NOT NULL,
                status VARCHAR(50) NOT NULL,
                description TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
            )
        `);
        console.log("✅ Migration: order_tracking table ready.");

        // 4. Seed default vouchers if they don't exist
        const [existingVouchers] = await pool.query('SELECT id FROM vouchers LIMIT 1');
        if (existingVouchers.length === 0) {
            await pool.query(`
                INSERT INTO vouchers (code, name, description, discount_type, discount_value, minimum_purchase, max_discount, is_active)
                VALUES 
                ('FIT10', 'Promo Fitness 10%', 'Potongan 10% untuk semua suplemen fitness', 'percentage', 10.00, 100000.00, 50000.00, 1),
                ('NEW50', 'Diskon Pengguna Baru', 'Potongan langsung Rp50.000 untuk minimal pembelian Rp150.000', 'fixed', 50000.00, 150000.00, 50000.00, 1),
                ('GYMBRO20', 'Gymbro Spesial 20%', 'Potongan 20% khusus pengguna Gymbro Pro', 'percentage', 20.00, 200000.00, 100000.00, 1)
            `);
            console.log("✅ Seed: Default vouchers inserted.");
        }

    } catch (error) {
        console.error("❌ Migration error (marketplace features):", error.message);
    }
}

module.exports = { runMarketplaceFeaturesMigration };
