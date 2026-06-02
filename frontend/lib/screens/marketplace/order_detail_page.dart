import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/supplement_service.dart';
import '../../utils/palette.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final SupplementService _supplementService = SupplementService();
  Order? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _supplementService.getOrderById(widget.orderId);
    if (mounted) {
      if (result['success']) {
        setState(() {
          _order = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : _error != null
              ? _buildErrorState()
              : _buildOrderDetails(),
    );
  }

  Widget _buildOrderDetails() {
    final order = _order!;
    final formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(order.date);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status Pesanan', style: TextStyle(color: kTextMuted, fontSize: 13)),
                    _buildStatusBadge(order.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('No. Pesanan', style: TextStyle(color: kTextMuted, fontSize: 13)),
                    Text(order.orderNumber, style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tanggal Transaksi', style: TextStyle(color: kTextMuted, fontSize: 13)),
                    Text(formattedDate, style: const TextStyle(color: kTextPrimary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Metode Pembayaran', style: TextStyle(color: kTextMuted, fontSize: 13)),
                    Text(order.paymentMethod ?? 'E-Wallet', style: const TextStyle(color: kTextPrimary, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Shipping Address Card
          const Text(
            'Informasi Pengiriman',
            style: TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: kAccent, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Alamat Tujuan',
                      style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order.shippingAddress ?? 'Jl. Kebugaran No. 8, Jakarta',
                  style: const TextStyle(color: kTextMuted, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Product list details
          const Text(
            'Daftar Produk',
            style: TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = order.items[index];
              final itemTotal = item.price * item.quantity;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fitness_center, color: kAccent, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kTextPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity} x Rp ${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(color: kTextMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Rp ${itemTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: kTextPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Pricing Summary Card
          const Text(
            'Rincian Pembayaran',
            style: TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(color: kTextMuted, fontSize: 13)),
                    Text('Rp ${order.subtotal.toStringAsFixed(0)}', style: const TextStyle(color: kTextPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (order.discount > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Diskon Voucher ${order.voucherCode != null ? "(${order.voucherCode})" : ""}',
                        style: const TextStyle(color: kTextMuted, fontSize: 13),
                      ),
                      Text('-Rp ${order.discount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
                const Divider(color: Colors.white10, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      'Rp ${order.total.toStringAsFixed(0)}',
                      style: const TextStyle(color: kAccent, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;

    switch (status.toLowerCase()) {
      case 'pending':
        bg = Colors.amber.withValues(alpha: 0.15);
        text = Colors.amber;
        break;
      case 'paid':
        bg = Colors.green.withValues(alpha: 0.15);
        text = Colors.green;
        break;
      case 'processing':
        bg = Colors.orange.withValues(alpha: 0.15);
        text = Colors.orange;
        break;
      case 'shipped':
        bg = Colors.blue.withValues(alpha: 0.15);
        text = Colors.blue;
        break;
      case 'completed':
        bg = Colors.grey.withValues(alpha: 0.15);
        text = Colors.grey;
        break;
      case 'cancelled':
        bg = Colors.red.withValues(alpha: 0.15);
        text = Colors.red;
        break;
      default:
        bg = Colors.white10;
        text = kTextPrimary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Terjadi kesalahan saat memuat data',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextPrimary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrderDetails,
              style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: kBg),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
