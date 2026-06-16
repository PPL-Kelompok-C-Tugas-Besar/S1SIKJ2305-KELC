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

  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Pending', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'];

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

  List<Order> get _filteredOrders {
    if (_selectedFilter == 'Semua') {
      return _orders;
    }
    return _orders.where((order) {
      final status = order.status.toLowerCase();
      if (_selectedFilter == 'Pending') return status == 'pending';
      if (_selectedFilter == 'Diproses') return status == 'paid' || status == 'processing';
      if (_selectedFilter == 'Dikirim') return status == 'shipped';
      if (_selectedFilter == 'Selesai') return status == 'completed';
      if (_selectedFilter == 'Dibatalkan') return status == 'cancelled';
      return false;
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredOrders;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
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
              'RIWAYAT TRANSAKSI',
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
      body: SafeArea(
        child: Column(
          children: [
            // Filter horizontal row
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return ChoiceChip(
                    label: Text(
                      filter.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: isSelected ? Colors.black : kTextPrimary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                    selectedColor: kAccent,
                    backgroundColor: kCard,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? kAccent : Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Orders List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadOrders,
                color: kAccent,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: kAccent))
                    : _error != null
                        ? _buildErrorState()
                        : filteredList.isEmpty
                            ? _buildEmptyState()
                            : _buildOrdersList(filteredList),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(order.date);
        final hasItems = order.items.isNotEmpty;
        final firstItem = hasItems ? order.items.first : null;

        return Container(
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailPage(orderId: order.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Invoice ID and Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(
                              color: kTextPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: kTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getStatusColor(order.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Colors.white10, height: 1),
                  ),

                  // Product Info Item (First Item placeholder)
                  if (firstItem != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Product Icon/Thumbnail
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: kBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(Icons.fitness_center, color: kAccent, size: 24),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Product details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstItem.productName,
                                style: const TextStyle(
                                  color: kTextPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${firstItem.quantity} barang x Rp ${firstItem.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: kTextMuted,
                                  fontSize: 12,
                                ),
                              ),
                              if (order.items.length > 1) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '+ ${order.items.length - 1} barang lainnya',
                                  style: const TextStyle(
                                    color: kTextMuted,
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Colors.white10, height: 1),
                  ),

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
                              fontWeight: FontWeight.w900,
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
          ),
        );
      },
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

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
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
                Icons.receipt_long_outlined,
                color: kTextMuted,
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Riwayat Belanja',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status filter: $_selectedFilter.\nYuk, belanja suplemen kesehatan Anda sekarang!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kTextMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
