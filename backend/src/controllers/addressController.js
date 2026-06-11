const { pool } = require('../config/db');

// Helper to parse complete_address into address, city, and postalCode
const parseCompleteAddress = (completeAddress) => {
    if (!completeAddress) {
        return { address: '', city: '', postalCode: '' };
    }

    // Replace newlines with comma-space to unify delimiters
    let unified = completeAddress.replace(/\r?\n/g, ', ');

    // Split by comma
    const parts = unified.split(',').map(p => p.trim()).filter(Boolean);

    if (parts.length >= 3) {
        const postalCode = parts[parts.length - 1];
        const city = parts[parts.length - 2];
        const address = parts.slice(0, parts.length - 2).join(', ');
        return { address, city, postalCode };
    } else if (parts.length === 2) {
        const cityOrPostal = parts[1];
        const address = parts[0];
        if (/^\d+$/.test(cityOrPostal)) {
            return { address, city: '', postalCode: cityOrPostal };
        } else {
            return { address, city: cityOrPostal, postalCode: '' };
        }
    } else {
        const match = completeAddress.match(/^(.*)\b(\d{5})$/s);
        if (match) {
            return { address: match[1].trim(), city: '', postalCode: match[2] };
        }
        return { address: completeAddress, city: '', postalCode: '' };
    }
};

// GET /api/users/addresses
const getAddresses = async (req, res) => {
    try {
        const userId = req.user.id;
        // Sort so default/utama comes first, then by id DESC
        const [rows] = await pool.query(
            'SELECT * FROM addresses WHERE user_id = ? ORDER BY is_default DESC, id DESC',
            [userId]
        );

        // Map database fields to frontend camelCase
        const formattedRows = rows.map(r => {
            const parsed = parseCompleteAddress(r.complete_address);
            return {
                id: r.id.toString(),
                user_id: r.user_id,
                name: r.recipient_name,
                phone: r.phone,
                address: parsed.address,
                city: parsed.city,
                postalCode: parsed.postalCode,
                isDefault: r.is_default === 1
            };
        });

        return res.status(200).json({ success: true, data: formattedRows });
    } catch (err) {
        console.error('Get addresses error:', err);
        return res.status(500).json({ success: false, message: 'Terjadi kesalahan saat mengambil alamat' });
    }
};

// POST /api/users/addresses
const addAddress = async (req, res) => {
    try {
        const userId = req.user.id;
        const { name, phone, address, city, postalCode, isDefault } = req.body;

        if (!name || !phone || !address || !city || !postalCode) {
            return res.status(400).json({ success: false, message: 'Semua field wajib diisi' });
        }

        // Check if user has no addresses yet
        const [countRows] = await pool.query(
            'SELECT COUNT(*) as count FROM addresses WHERE user_id = ?',
            [userId]
        );
        const hasNoAddresses = countRows[0].count === 0;
        const shouldBeDefault = hasNoAddresses || isDefault === true;

        if (shouldBeDefault) {
            // Set all other addresses for this user to non-default
            await pool.execute(
                'UPDATE addresses SET is_default = FALSE WHERE user_id = ?',
                [userId]
            );
        }

        const completeAddress = `${address}, ${city}, ${postalCode}`;
        const [result] = await pool.execute(
            'INSERT INTO addresses (user_id, label, recipient_name, phone, complete_address, is_default) VALUES (?, ?, ?, ?, ?, ?)',
            [userId, 'Alamat', name, phone, completeAddress, shouldBeDefault ? 1 : 0]
        );

        const newId = result.insertId;
        return res.status(201).json({
            success: true,
            message: 'Alamat berhasil ditambahkan',
            data: {
                id: newId.toString(),
                user_id: userId,
                name,
                phone,
                address,
                city,
                postalCode,
                isDefault: shouldBeDefault
            }
        });
    } catch (err) {
        console.error('Add address error:', err);
        return res.status(500).json({ success: false, message: 'Terjadi kesalahan saat menambahkan alamat' });
    }
};

// PUT /api/users/addresses/:id
const updateAddress = async (req, res) => {
    try {
        const userId = req.user.id;
        const addressId = req.params.id;
        const { name, phone, address, city, postalCode, isDefault } = req.body;

        if (!name || !phone || !address || !city || !postalCode) {
            return res.status(400).json({ success: false, message: 'Semua field wajib diisi' });
        }

        // Verify the address belongs to user
        const [exists] = await pool.execute(
            'SELECT is_default FROM addresses WHERE id = ? AND user_id = ?',
            [addressId, userId]
        );
        if (exists.length === 0) {
            return res.status(404).json({ success: false, message: 'Alamat tidak ditemukan' });
        }

        // If setting this to default, make other user addresses non-default
        if (isDefault === true) {
            await pool.execute(
                'UPDATE addresses SET is_default = FALSE WHERE user_id = ?',
                [userId]
            );
        }

        const completeAddress = `${address}, ${city}, ${postalCode}`;
        await pool.execute(
            'UPDATE addresses SET label = ?, recipient_name = ?, phone = ?, complete_address = ?, is_default = ? WHERE id = ? AND user_id = ?',
            ['Alamat', name, phone, completeAddress, isDefault ? 1 : 0, addressId, userId]
        );

        return res.status(200).json({
            success: true,
            message: 'Alamat berhasil diperbarui',
            data: {
                id: addressId,
                user_id: userId,
                name,
                phone,
                address,
                city,
                postalCode,
                isDefault: isDefault === true
            }
        });
    } catch (err) {
        console.error('Update address error:', err);
        return res.status(500).json({ success: false, message: 'Terjadi kesalahan saat memperbarui alamat' });
    }
};

// DELETE /api/users/addresses/:id
const deleteAddress = async (req, res) => {
    try {
        const userId = req.user.id;
        const addressId = req.params.id;

        // Check if the address being deleted is currently the default/utama
        const [targetAddress] = await pool.execute(
            'SELECT is_default FROM addresses WHERE id = ? AND user_id = ?',
            [addressId, userId]
        );

        if (targetAddress.length === 0) {
            return res.status(404).json({ success: false, message: 'Alamat tidak ditemukan atau bukan milik Anda' });
        }

        const wasDefault = targetAddress[0].is_default === 1;

        const [result] = await pool.execute(
            'DELETE FROM addresses WHERE id = ? AND user_id = ?',
            [addressId, userId]
        );

        // If default address was deleted, set another remaining address as default
        if (wasDefault) {
            const [remaining] = await pool.query(
                'SELECT id FROM addresses WHERE user_id = ? ORDER BY id DESC LIMIT 1',
                [userId]
            );
            if (remaining.length > 0) {
                await pool.execute(
                    'UPDATE addresses SET is_default = TRUE WHERE id = ?',
                    [remaining[0].id]
                );
            }
        }

        return res.status(200).json({ success: true, message: 'Alamat berhasil dihapus' });
    } catch (err) {
        console.error('Delete address error:', err);
        return res.status(500).json({ success: false, message: 'Terjadi kesalahan saat menghapus alamat' });
    }
};

module.exports = { getAddresses, addAddress, updateAddress, deleteAddress };
