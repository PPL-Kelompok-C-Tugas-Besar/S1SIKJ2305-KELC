import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/palette.dart';
import '../../models/voucher_model.dart';
import '../../services/supplement_service.dart';
import 'voucher_selection_sheet.dart';
import 'purchase_history_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'STORE',
              style: TextStyle(
                color: kTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'CART',
              style: TextStyle(
                color: kTextPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 24,
              ),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                _confirmClearCart(context, cartProvider);
              },
              child: const Text('Clear', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final product = item.product;
                      final subtotal = product.price * item.quantity;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 70,
                                height: 70,
                                color: kBg,
                                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        product.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: kTextMuted),
                                      )
                                    : const Icon(Icons.fitness_center, color: kTextMuted),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Product details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: kTextPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(color: kTextMuted, fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  // Subtotal text
                                  Text(
                                    'Subtotal: Rp ${subtotal.toStringAsFixed(0)}',
                                    style: const TextStyle(color: kAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity controls & delete
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () {
                                    cartProvider.removeFromCart(product.id);
                                  },
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: kBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          cartProvider.decrementQuantity(product.id);
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Icon(Icons.remove, color: kTextPrimary, size: 16),
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          color: kTextPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          cartProvider.incrementQuantity(product.id);
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Icon(Icons.add, color: kTextPrimary, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Order Summary Panel
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Voucher selection row
                        InkWell(
                          onTap: () async {
                            final selected = await showModalBottomSheet<Voucher?>(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => VoucherSelectionSheet(
                                currentSubtotal: cartProvider.totalPrice,
                                selectedVoucher: cartProvider.appliedVoucher,
                              ),
                            );
                            if (context.mounted) {
                              cartProvider.applyVoucher(selected);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: kBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.confirmation_number_outlined, color: kAccent, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    cartProvider.appliedVoucher != null
                                        ? 'Voucher Terpasang: ${cartProvider.appliedVoucher!.code}'
                                        : 'Gunakan Voucher Promo',
                                    style: TextStyle(
                                      color: cartProvider.appliedVoucher != null ? kTextPrimary : kTextMuted,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (cartProvider.appliedVoucher != null)
                                  const Icon(Icons.check_circle, color: kAccent, size: 20)
                                else
                                  const Icon(Icons.arrow_forward_ios, color: kTextMuted, size: 14),
                              ],
                            ),
                          ),
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Item', style: TextStyle(color: kTextMuted, fontSize: 15)),
                            Text('${cartProvider.totalItems} item', style: const TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: TextStyle(color: kTextMuted, fontSize: 15)),
                            Text('Rp ${cartProvider.totalPrice.toStringAsFixed(0)}', style: const TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (cartProvider.discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Diskon Voucher', style: TextStyle(color: kTextMuted, fontSize: 15)),
                              Text('-Rp ${cartProvider.discountAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: kTextMuted, height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Pembayaran', style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
                            Text(
                              'Rp ${cartProvider.finalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(color: kAccent, fontSize: 22, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Checkout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _handleCheckout(context, cartProvider);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 18.0),
                              elevation: 8,
                              shadowColor: kAccent.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                            child: const Text(
                              'CHECKOUT',
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
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kCard,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: kTextMuted,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Keranjang belanja kosong',
              style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan beberapa suplemen fitness terbaik pilihan Anda ke dalam keranjang belanja.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextMuted, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: kBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 0,
              ),
              child: const Text('Mulai Belanja', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearCart(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Bersihkan Keranjang', style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus semua item dari keranjang belanja?', style: TextStyle(color: kTextMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(BuildContext context, CartProvider cart) {
    if (cart.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang Anda kosong!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final SupplementService supplementService = SupplementService();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) {
        Future.microtask(() async {
          final body = {
            'subtotal': cart.totalPrice,
            'voucher_code': cart.appliedVoucher?.code,
            'payment_method': 'E-Wallet',
            'shipping_address': 'Jl. Kebugaran No. 8, Jakarta',
            'items': cart.cartItems.map((e) => {
              'product_id': e.product.id,
              'product_name': e.product.name,
              'quantity': e.quantity,
              'price': e.product.price,
            }).toList(),
          };

          final result = await supplementService.createOrder(body);

          if (loadingContext.mounted) {
            Navigator.pop(loadingContext); // Close loader
          }

          if (context.mounted) {
            if (result['success']) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  backgroundColor: kCard,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      const Icon(Icons.check_circle_outline, color: kAccent, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Checkout Berhasil!',
                        style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pesanan Anda sedang diproses. Silakan cek status pesanan secara berkala.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kTextMuted, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            cart.clearCart();
                            Navigator.pop(context); // Close success dialog
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const PurchaseHistoryPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccent,
                            foregroundColor: kBg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text('Lihat Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Gagal memproses checkout'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          }
        });

        return AlertDialog(
          backgroundColor: kCard,
          content: Row(
            children: const [
              CircularProgressIndicator(color: kAccent),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Sedang memproses transaksi Anda...',
                  style: TextStyle(color: kTextPrimary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
