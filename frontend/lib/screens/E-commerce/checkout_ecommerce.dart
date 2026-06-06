import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AppColors {
  static const Color bgColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF292929);
  static const Color accentColor = Color(0xFFCCFF00);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);
}

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final int subtotal;
  final int shippingCost;

  const CheckoutPage({
    super.key,
    required this.selectedItems,
    required this.subtotal,
    required this.shippingCost,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool isOrdering = false;
  String _selectedPayment = 'QRIS';

  // Dummy address — address management is a future sprint
  final Map<String, String> _dummyAddress = {
    'name': 'John Doe',
    'phone': '+62 812-3456-7890',
    'address': 'Jl. Agartha No. 9, Kel. Sehat, Kec. Fit',
    'city': 'Jakarta Selatan, 12345',
  };

  int get totalCost => widget.subtotal + widget.shippingCost;

  String formatRupiah(int number) {
    String numStr = number.toString();
    String result = '';
    for (int i = 0; i < numStr.length; i++) {
      if (i > 0 && (numStr.length - i) % 3 == 0) {
        result += '.';
      }
      result += numStr[i];
    }
    return 'Rp $result';
  }

  Future<void> _placeOrder() async {
    setState(() => isOrdering = true);

    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse('http://localhost:3000/checkout/order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'items': widget.selectedItems.map((item) => {
            'product_id': item['product_id'],
            'quantity': item['quantity'],
            'price': item['price'],
            'cart_id': item['id'], // item['id'] is cart_id in cart_ecommerce
          }).toList(),
          'payment_method': _selectedPayment,
          'shipping_address': _dummyAddress['address'],
          'total': totalCost,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201 && data['success'] == true) {
        setState(() => isOrdering = false);
        _showOrderSuccessDialog();
      } else {
        _showErrorSnackbar(data['message'] ?? 'Pesanan gagal diproses');
      }
    } catch (e) {
      if (mounted) _showErrorSnackbar('Terjadi kesalahan koneksi server');
    } finally {
      if (mounted) setState(() => isOrdering = false);
    }
  }

  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: Stack(
          children: [
            // Close Button (X)
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                splashRadius: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        color: AppColors.accentColor, size: 56),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Order Placed!',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pesanan kamu berhasil dibuat.\nTerima kasih sudah belanja di Gymbro!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'SHOP',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'CHECKOUT',
              style: TextStyle(
                color: AppColors.textPrimary,
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
                    _buildSectionLabel('ORDER SUMMARY'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
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
                    _buildSectionLabel('PRICE BREAKDOWN'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow('Subtotal', formatRupiah(widget.subtotal), isTotal: false),
                          const SizedBox(height: 10),
                          _buildPriceRow('Shipping', formatRupiah(widget.shippingCost), isTotal: false),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(color: AppColors.textSecondary, height: 1),
                          ),
                          _buildPriceRow('Total', formatRupiah(totalCost), isTotal: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Delivery Address ─────────────────────────
                    _buildSectionLabel('DELIVERY ADDRESS'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accentColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.location_on_rounded,
                                color: AppColors.accentColor, size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _dummyAddress['name']!,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _dummyAddress['phone']!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${_dummyAddress['address']!}\n${_dummyAddress['city']!}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Payment Method ────────────────────────────
                    _buildSectionLabel('PAYMENT METHOD'),
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
                color: AppColors.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
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
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        formatRupiah(totalCost),
                        style: const TextStyle(
                          color: AppColors.accentColor,
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
                      onPressed: isOrdering ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        elevation: 8,
                        shadowColor: AppColors.accentColor.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: isOrdering
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2.5),
                            )
                          : const Text(
                              'PLACE ORDER',
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

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
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
                  color: AppColors.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item['image'] != null &&
                          item['image'].toString().startsWith('http')
                      ? Image.network(
                          item['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.fitness_center,
                                color: AppColors.textSecondary),
                          ),
                        )
                      : Image.asset(
                          item['image'] ?? 'assets/whey.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.fitness_center,
                                color: AppColors.textSecondary),
                          ),
                        ),
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
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
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      'x${item['quantity']}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Text(
                _formatItemPrice(item),
                style: const TextStyle(
                  color: AppColors.accentColor,
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

  String _formatItemPrice(Map<String, dynamic> item) {
    final price = item['price'] as int? ?? 0;
    final qty = item['quantity'] as int? ?? 1;
    final total = price * qty;
    String numStr = total.toString();
    String result = '';
    for (int i = 0; i < numStr.length; i++) {
      if (i > 0 && (numStr.length - i) % 3 == 0) result += '.';
      result += numStr[i];
    }
    return 'Rp $result';
  }

  Widget _buildPriceRow(String label, String value, {required bool isTotal}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? AppColors.accentColor : AppColors.textPrimary,
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
          ),
        ),
      ],
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
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentColor.withOpacity(0.15)
                    : AppColors.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.accentColor : AppColors.textSecondary,
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
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
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
                  color: isSelected ? AppColors.accentColor : AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.accentColor,
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
}
