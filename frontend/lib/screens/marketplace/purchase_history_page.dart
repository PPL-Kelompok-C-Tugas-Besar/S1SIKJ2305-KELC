import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/supplement_service.dart';
import '../../utils/palette.dart';
import 'order_detail_page.dart';

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  final SupplementService _supplementService = SupplementService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _supplementService.getOrders();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _orders = result['data'];
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
          onPressed: () {
            // Check if we can pop, otherwise go home
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        title: const Text(
          'Riwayat Pembelian',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        color: kAccent,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: kAccent))
            : _error != null
                ? _buildErrorState()
                : _orders.isEmpty
                    ? _buildEmptyState()
                    : _buildOrdersList(),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final order = _orders[index];
        final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(order.date);

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailPage(orderId: order.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Order Number & Status)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        color: kTextPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    _buildStatusBadge(order.status),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Date
                Text(
                  formattedDate,
                  style: const TextStyle(color: kTextMuted, fontSize: 12),
                ),
                const Divider(color: Colors.white10, height: 20),

                // Total & Summary info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(color: kTextMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${order.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: kAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Text(
                          'Detail',
                          style: TextStyle(color: kTextPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, color: kTextPrimary, size: 12),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
              onPressed: _loadOrders,
              style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: kBg),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        alignment: Alignment.center,
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
                Icons.history_toggle_off,
                color: kTextMuted,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada riwayat pembelian.',
              style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ayo temukan suplemen terbaik Anda di Gymbro Store dan mulai transaksi pertama!',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextMuted, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
