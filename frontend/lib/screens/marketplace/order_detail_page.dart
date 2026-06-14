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
  @override
  Widget build(BuildContext context) {
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
              'DETAIL TRANSAKSI',
              style: TextStyle(
                color: kTextPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : _error != null
              ? _buildErrorState()
              : _buildOrderDetails(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orangeAccent;
      case 'paid':
        return Colors.green;
      case 'processing':
        return Colors.blueAccent;
      case 'shipped':
        return kAccent;
      case 'completed':
        return kAccent;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return kTextMuted;
    }
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
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
          const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Text(
              'Informasi Pengiriman',
              style: TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
          const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Text(
              'Daftar Produk',
              style: TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.bold),
            ),
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
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
          const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Text(
              'Rincian Pembayaran',
              style: TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
                      style: const TextStyle(color: kAccent, fontSize: 18, fontWeight: FontWeight.bold),
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
    final statusColor = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: statusColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('COBA LAGI', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
