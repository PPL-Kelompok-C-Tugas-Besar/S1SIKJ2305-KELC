// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN SYSTEM
// ─────────────────────────────────────────────────────────────────────────────
class _AppColors {
  static const Color bgColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF292929);
  static const Color accentColor = Color(0xFFCCFF00);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK CART PAGE  ──  UI tiruan dari cart_ecommerce.dart
// ─────────────────────────────────────────────────────────────────────────────
class _MockCartPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialItems;
  const _MockCartPage({required this.initialItems});

  @override
  State<_MockCartPage> createState() => _MockCartPageState();
}

class _MockCartPageState extends State<_MockCartPage> {
  late List<Map<String, dynamic>> cartItems;

  @override
  void initState() {
    super.initState();
    cartItems = widget.initialItems.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  String formatRupiah(int n) {
    final s = n.toString();
    String r = '';
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) r += '.';
      r += s[i];
    }
    return 'Rp $r';
  }

  int get subtotal => cartItems.fold(
        0,
        (sum, item) =>
            item['selected'] == true ? sum + (item['price'] as int) * (item['quantity'] as int) : sum,
      );

  int get shippingCost => subtotal > 0 ? 50000 : 0;
  int get totalCost => subtotal + shippingCost;

  void toggleSelection(int index, bool? value) {
    setState(() => cartItems[index]['selected'] = value ?? false);
  }

  void _goToCheckout() {
    final selected = cartItems.where((e) => e['selected'] == true).toList();
    if (selected.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MockCheckoutPage(
          selectedItems: selected,
          subtotal: subtotal,
          shippingCost: shippingCost,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _AppColors.textPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('SHOP',
                style: TextStyle(
                    color: _AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0)),
            Text('CART',
                style: TextStyle(
                    color: _AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 24)),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.shopping_cart_outlined, size: 80, color: _AppColors.textSecondary),
                          SizedBox(height: 16),
                          Text('Your cart is empty',
                              style: TextStyle(
                                  color: _AppColors.textSecondary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (_, idx) => _buildCartItem(cartItems[idx], idx),
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _AppColors.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal',
                          style: TextStyle(color: _AppColors.textSecondary, fontSize: 16)),
                      Text(formatRupiah(subtotal),
                          style: const TextStyle(
                              color: _AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Shipping',
                          style: TextStyle(color: _AppColors.textSecondary, fontSize: 16)),
                      Text(formatRupiah(shippingCost),
                          style: const TextStyle(
                              color: _AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: _AppColors.textSecondary, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              color: _AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900)),
                      Text(formatRupiah(totalCost),
                          style: const TextStyle(
                              color: _AppColors.accentColor, fontSize: 24, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('checkout_button'),
                      onPressed: cartItems.isEmpty ? null : _goToCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.accentColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('CHECKOUT',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item['selected'] == true
              ? _AppColors.accentColor.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: item['selected'] ?? false,
            onChanged: (v) => toggleSelection(index, v),
            activeColor: _AppColors.accentColor,
            checkColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                color: _AppColors.bgColor, borderRadius: BorderRadius.circular(12)),
            child: const Center(
              child: Icon(Icons.fitness_center, color: _AppColors.textSecondary, size: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'],
                    style: const TextStyle(
                        color: _AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(item['variant'] ?? 'Standard',
                    style: const TextStyle(color: _AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatRupiah(item['price'] as int),
                        style: const TextStyle(
                            color: _AppColors.accentColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 16)),
                    Container(
                      decoration: BoxDecoration(
                          color: _AppColors.bgColor, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: const Icon(Icons.remove, size: 16, color: _AppColors.textPrimary),
                          ),
                          Text('${item['quantity']}',
                              style: const TextStyle(
                                  color: _AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: const Icon(Icons.add, size: 16, color: _AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
            onPressed: () {},
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.only(bottom: 40, left: 8),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK CHECKOUT PAGE  ──  UI tiruan dari checkout_ecommerce.dart
// ─────────────────────────────────────────────────────────────────────────────
class _MockCheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final int subtotal;
  final int shippingCost;

  const _MockCheckoutPage({
    required this.selectedItems,
    required this.subtotal,
    required this.shippingCost,
  });

  @override
  State<_MockCheckoutPage> createState() => _MockCheckoutPageState();
}

class _MockCheckoutPageState extends State<_MockCheckoutPage> {
  bool _orderPlaced = false;
  String _selectedPayment = 'QRIS';

  final Map<String, String> _address = {
    'name': 'Budi Santoso',
    'phone': '081234567890',
    'address': 'Jl. Sudirman No. 42',
    'city': 'Jakarta Selatan',
    'postalCode': '12190',
  };

  String formatRupiah(int n) {
    final s = n.toString();
    String r = '';
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) r += '.';
      r += s[i];
    }
    return 'Rp $r';
  }

  int get totalCost => widget.subtotal + widget.shippingCost;

  void _placeOrder() => setState(() => _orderPlaced = true);

  @override
  Widget build(BuildContext context) {
    if (_orderPlaced) {
      return Scaffold(
        backgroundColor: _AppColors.bgColor,
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            decoration: BoxDecoration(
              color: _AppColors.cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _AppColors.accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      size: 56, color: _AppColors.accentColor),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pesanan Berhasil!',
                  key: Key('order_success_title'),
                  style: TextStyle(
                    color: _AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pesananmu sedang diproses',
                  key: Key('order_success_subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('btn_back_to_shop'),
                    onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _AppColors.accentColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Kembali ke Shop',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _AppColors.textPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'SHOP',
              style: TextStyle(
                color: _AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'CHECKOUT',
              style: TextStyle(
                color: _AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 24,
              ),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Order Items ──────────────────────────────
                    _sectionLabel('ORDER SUMMARY'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: _AppColors.cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          ...widget.selectedItems.asMap().entries.map((entry) {
                            final i = entry.key;
                            final item = entry.value;
                            final isLast = i == widget.selectedItems.length - 1;
                            return _buildOrderItem(item, isLast);
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Price Breakdown ──────────────────────────
                    _sectionLabel('PRICE BREAKDOWN'),
                    const SizedBox(height: 12),
                    _buildPriceDetail(),

                    const SizedBox(height: 24),

                    // ── Delivery Address ─────────────────────────
                    _sectionLabel('SHIPPING ADDRESS'),
                    const SizedBox(height: 12),
                    _buildAddressCard(),

                    const SizedBox(height: 24),

                    // ── Payment Method ────────────────────────────
                    _sectionLabel('PAYMENT METHOD'),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      value: 'QRIS',
                      label: 'QRIS',
                      subtitle: 'Scan QR bisa dari semua e-wallet',
                      icon: Icons.qr_code_2_rounded,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      value: 'COD',
                      label: 'Cash on Delivery (COD)',
                      subtitle: 'Bayar saat barang sampai',
                      icon: Icons.payments_outlined,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Bottom Order Button ───────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: _AppColors.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          color: _AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        formatRupiah(totalCost),
                        style: const TextStyle(
                          color: _AppColors.accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('place_order_button'),
                      onPressed: _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.accentColor,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: _AppColors.textSecondary.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        elevation: 8,
                        shadowColor: _AppColors.accentColor.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: const Text(
                        'PLACE ORDER',
                        key: Key('place_order_text'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _AppColors.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.fitness_center,
                      color: _AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 14),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'Unknown Product',
                      key: Key('checkout_item_name_${item['name']}'),
                      style: const TextStyle(
                        color: _AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item['variant'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item['variant'],
                        style: const TextStyle(
                            color: _AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      'x${item['quantity']}',
                      style: const TextStyle(
                        color: _AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Text(
                formatRupiah((item['price'] as int) * (item['quantity'] as int)),
                key: Key('checkout_item_price_${item['name']}'),
                style: const TextStyle(
                  color: _AppColors.accentColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1,
              color: Color(0xFF3A3A3A),
              indent: 16,
              endIndent: 16),
      ],
    );
  }

  Widget _buildAddressCard() {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _AppColors.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _AppColors.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_rounded,
                color: _AppColors.accentColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          _address['name']!,
                          key: const Key('checkout_address_name'),
                          style: const TextStyle(
                            color: _AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _AppColors.accentColor
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: _AppColors.accentColor,
                                width: 1),
                          ),
                          child: const Text(
                            'Utama',
                            style: TextStyle(
                              color: _AppColors.accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Ubah',
                      style: TextStyle(
                        color: _AppColors.accentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _address['phone']!,
                  key: const Key('checkout_address_phone'),
                  style: const TextStyle(
                    color: _AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_address['address']!}\n${_address['city']!}, ${_address['postalCode']!}',
                  key: const Key('checkout_address_detail'),
                  style: const TextStyle(
                    color: _AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String label,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _AppColors.accentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? _AppColors.accentColor.withValues(alpha: 0.15)
                    : _AppColors.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? _AppColors.accentColor : _AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? _AppColors.textPrimary : _AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _AppColors.accentColor : _AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: _AppColors.accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {required bool isTotal}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? _AppColors.textPrimary : _AppColors.textSecondary,
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          key: isTotal ? const Key('checkout_total_price') : null,
          style: TextStyle(
            color: isTotal ? _AppColors.accentColor : _AppColors.textPrimary,
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetail() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', formatRupiah(widget.subtotal), isTotal: false),
          const SizedBox(height: 10),
          _buildPriceRow('Shipping', formatRupiah(widget.shippingCost), isTotal: false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: _AppColors.textSecondary, height: 1),
          ),
          _buildPriceRow('Total', formatRupiah(totalCost), isTotal: true),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TEST RUNNER  ──  TS.SP-5: State Transition Cart → Checkout → Order
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp(Widget home) => MaterialApp(home: home);

  Future<void> pump(WidgetTester t, {int ms = 500}) async {
    await t.pump(Duration(milliseconds: ms));
    await t.pumpAndSettle();
  }

  Map<String, dynamic> makeItem({int qty = 2, bool selected = true}) => {
        'id': '101',
        'name': 'Optimum Nutrition Whey Protein',
        'variant': 'Standard',
        'price': 450000,
        'quantity': qty,
        'stock': 10,
        'selected': selected,
      };

  // ════════════════════════════════════════════════════════════════════════════
  //  TS.SP-5 — State Transition: Cart → Checkout → Order Placed
  // ════════════════════════════════════════════════════════════════════════════
  group('TS.SP-5 | State Transition – Cart ke Checkout ke Order', () {
    // TC.SP-5.001 ── Navigasi dari Cart ke halaman Checkout ───────────────────
    testWidgets('TC.SP-5.001 | Cart → Checkout: navigasi berhasil',
        (tester) async {
      await tester.pumpWidget(buildApp(
        _MockCartPage(initialItems: [makeItem()]),
      ));
      await pump(tester);

      // Verifikasi: halaman Cart tampil
      expect(find.text('CART'), findsOneWidget);
      expect(find.text('Optimum Nutrition Whey Protein'), findsOneWidget);

      // Klik tombol CHECKOUT
      await tester.tap(find.byKey(const Key('checkout_button')));
      await pump(tester);

      // Expected: masuk halaman Checkout
      expect(find.text('ORDER SUMMARY'), findsOneWidget);
      expect(find.text('CHECKOUT'), findsOneWidget);
    });

    // TC.SP-5.002 ── Verifikasi nama produk, harga, dan alamat di Checkout ────
    testWidgets(
        'TC.SP-5.002 | Checkout: nama produk, harga, dan alamat tampil benar',
        (tester) async {
      await tester.pumpWidget(buildApp(
        _MockCartPage(initialItems: [makeItem(qty: 2)]),
      ));
      await pump(tester);

      await tester.tap(find.byKey(const Key('checkout_button')));
      await pump(tester);

      // Nama produk tampil di checkout
      expect(
        find.byKey(const Key('checkout_item_name_Optimum Nutrition Whey Protein')),
        findsOneWidget,
      );

      // Harga item: 450.000 × 2 = 900.000
      expect(
        find.byKey(const Key('checkout_item_price_Optimum Nutrition Whey Protein')),
        findsOneWidget,
      );
      // findsWidgets: muncul di item row DAN price detail section
      expect(find.text('Rp 900.000'), findsWidgets);

      // Nama & nomor HP pada alamat pengiriman
      expect(find.byKey(const Key('checkout_address_name')), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.byKey(const Key('checkout_address_phone')), findsOneWidget);
      expect(find.text('081234567890'), findsOneWidget);

      // Label section alamat
      expect(find.text('SHIPPING ADDRESS'), findsOneWidget);
    });

    // TC.SP-5.003 ── Klik Bayar → state berubah ke "Pesanan Berhasil!" ────────
    testWidgets(
        'TC.SP-5.003 | Checkout → Place Order → tampil konfirmasi berhasil',
        (tester) async {
      await tester.pumpWidget(buildApp(
        _MockCartPage(initialItems: [makeItem(qty: 2)]),
      ));
      await pump(tester);

      // Navigasi ke Checkout
      await tester.tap(find.byKey(const Key('checkout_button')));
      await pump(tester);

      // Verifikasi tombol bayar ada
      expect(find.byKey(const Key('place_order_button')), findsOneWidget);

      // Scroll ke tombol (pastikan tidak off-screen)
      await tester.ensureVisible(find.byKey(const Key('place_order_button')));
      await tester.pumpAndSettle();

      // Klik tombol bayar
      await tester.tap(find.byKey(const Key('place_order_button')), warnIfMissed: false);
      await pump(tester);

      // Expected: halaman konfirmasi "Pesanan Berhasil!"
      expect(find.byKey(const Key('order_success_title')), findsOneWidget);
      expect(find.text('Pesanan Berhasil!'), findsOneWidget);
      expect(find.byKey(const Key('order_success_subtitle')), findsOneWidget);
      expect(find.text('Pesananmu sedang diproses'), findsOneWidget);

      // Tombol kembali ke shop
      expect(find.byKey(const Key('btn_back_to_shop')), findsOneWidget);
    });
  });
}
