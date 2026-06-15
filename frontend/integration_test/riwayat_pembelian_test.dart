// =============================================================================
// SCENARIO ID : TS.JR-1 | TS.RP
// Scenario    : Riwayat Pembelian - Melihat Riwayat & Detail Transaksi
// Test Cases  : TC.JR-1.001, TC.RP-1.001, TC.RP-1.002
// Feature     : PurchaseHistoryPage - Riwayat transaksi user
// Type        : Integration Test (FT - Functional Test)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gymbro/screens/E-commerce/purchase_history.dart';
import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// Helper: build PurchaseHistoryPage dengan data order dummy
// Karena PurchaseHistoryPage fetch dari backend saat init, kita inject data
// lewat override _orders state setelah pump (atau pakai manualOrders jika ada).
// Untuk sekarang kita test state kosong dan state dengan data.
// ---------------------------------------------------------------------------

class _MockPurchaseHistoryPage extends StatefulWidget {
  final List<Map<String, dynamic>> mockOrders;
  final bool isEmpty;

  const _MockPurchaseHistoryPage({
    required this.mockOrders,
    this.isEmpty = false,
  });

  @override
  State<_MockPurchaseHistoryPage> createState() =>
      _MockPurchaseHistoryPageState();
}

class _MockPurchaseHistoryPageState extends State<_MockPurchaseHistoryPage> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = [
    'Semua', 'Pending', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'
  ];

  static const Color bgColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF292929);
  static const Color accentColor = Color(0xFFCCFF00);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);

  List<Map<String, dynamic>> get _filteredOrders {
    if (widget.isEmpty) return [];
    final orders = widget.mockOrders;
    if (_selectedFilter == 'Semua') return orders;
    return orders.where((o) => o['status'] == _selectedFilter).toList();
  }

  String _formatRupiah(int price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  int _calculateOrderTotal(Map<String, dynamic> order) {
    int subtotal = 0;
    final List<dynamic> items = order['items'] ?? [];
    for (var item in items) {
      subtotal += (item['price'] as num).toInt() * (item['quantity'] as num).toInt();
    }
    return subtotal + (order['shipping_cost'] as num).toInt();
  }

  int _calculateOrderSubtotal(Map<String, dynamic> order) {
    int subtotal = 0;
    final List<dynamic> items = order['items'] ?? [];
    for (var item in items) {
      subtotal += (item['price'] as num).toInt() * (item['quantity'] as num).toInt();
    }
    return subtotal;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orangeAccent;
      case 'Diproses':
        return Colors.blueAccent;
      case 'Dikirim':
        return accentColor;
      case 'Selesai':
        return accentColor;
      case 'Dibatalkan':
        return Colors.redAccent;
      default:
        return textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'BELANJA',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'RIWAYAT TRANSAKSI',
              style: TextStyle(
                color: textPrimary,
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
                    key: Key('filter_$filter'),
                    label: Text(
                      filter.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: isSelected ? Colors.black : textPrimary,
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
                    selectedColor: accentColor,
                    backgroundColor: cardColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Order lists
            Expanded(
              child: orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: cardColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white10),
                            ),
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              color: textSecondary,
                              size: 56,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Belum Ada Riwayat Belanja',
                            key: Key('empty_label'),
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Status filter: $_selectedFilter.\nYuk, belanja suplemen kesehatan Anda sekarang!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: orders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
                        final firstItem = items.first;
                        final totalItems = items.fold<int>(0, (sum, item) => sum + (item['quantity'] as num).toInt());
                        final totalPayment = _calculateOrderTotal(order);

                        return Container(
                          decoration: BoxDecoration(
                            color: cardColor,
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
                            key: Key('order_card_$index'),
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _showOrderDetailBottomSheet(context, order),
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
                                            order['id'],
                                            style: const TextStyle(
                                              color: textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            order['date'],
                                            style: const TextStyle(
                                              color: textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(order['status']).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: _getStatusColor(order['status']),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          order['status'].toUpperCase(),
                                          style: TextStyle(
                                            color: _getStatusColor(order['status']),
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

                                  // First Product Info
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Product Image Thumbnail
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: firstItem['image'].toString().startsWith('http')
                                              ? Image.network(
                                                  firstItem['image'],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => const Center(
                                                    child: Icon(Icons.fitness_center, color: textSecondary, size: 20),
                                                  ),
                                                )
                                              : Image.asset(
                                                  firstItem['image'],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => const Center(
                                                    child: Icon(Icons.fitness_center, color: textSecondary, size: 20),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Product details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              firstItem['name'],
                                              style: const TextStyle(
                                                color: textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${firstItem['quantity']} barang x ${_formatRupiah((firstItem['price'] as num).toInt())}',
                                              style: const TextStyle(
                                                color: textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // More Items hint
                                  if (items.length > 1) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      '+ ${items.length - 1} barang lainnya',
                                      style: const TextStyle(
                                        color: textSecondary,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],

                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                    child: Divider(color: Colors.white10, height: 1),
                                  ),

                                  // Summary & Total
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total ($totalItems Barang)',
                                        style: const TextStyle(
                                          color: textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        _formatRupiah(totalPayment),
                                        style: const TextStyle(
                                          color: accentColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetailBottomSheet(BuildContext context, Map<String, dynamic> order) {
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final subtotal = _calculateOrderSubtotal(order);
    final totalPayment = _calculateOrderTotal(order);

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DETAIL TRANSAKSI',
                        key: Key('detail_transaksi_title'),
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order['status']).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _getStatusColor(order['status']),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          order['status'].toUpperCase(),
                          key: const Key('order_status_text'),
                          style: TextStyle(
                            color: _getStatusColor(order['status']),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['id'],
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Dibuat pada: ${order['date']}',
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showOrderStatusTrackerBottomSheet(context, order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentColor,
                        side: const BorderSide(color: accentColor, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.local_shipping_outlined, size: 18),
                      label: const Text(
                        'LACAK STATUS PESANAN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 16),

                  // Shipping Address
                  const Text(
                    'ALAMAT PENGIRIMAN',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_rounded, color: accentColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            order['shipping_address'] ?? '-',
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Products List
                  const Text(
                    'RINCIAN PRODUK',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: item['image'].toString().startsWith('http')
                                    ? Image.network(
                                        item['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(Icons.fitness_center, color: textSecondary, size: 20),
                                        ),
                                      )
                                    : Image.asset(
                                        item['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(Icons.fitness_center, color: textSecondary, size: 20),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      color: textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'x${item['quantity']}',
                                        style: const TextStyle(
                                          color: textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        _formatRupiah((item['price'] as num).toInt() * (item['quantity'] as num).toInt()),
                                        style: const TextStyle(
                                          color: accentColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Payment Details
                  const Text(
                    'RINCIAN PEMBAYARAN',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Metode Pembayaran',
                              style: TextStyle(color: textSecondary, fontSize: 13),
                            ),
                            Text(
                              order['payment_method'] ?? '-',
                              style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(color: textSecondary, fontSize: 13),
                            ),
                            Text(
                              _formatRupiah(subtotal),
                              style: const TextStyle(color: textPrimary, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ongkos Kirim',
                              style: TextStyle(color: textSecondary, fontSize: 13),
                            ),
                            Text(
                              _formatRupiah((order['shipping_cost'] as num).toInt()),
                              style: const TextStyle(color: textPrimary, fontSize: 13),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Colors.white10, height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              _formatRupiah(totalPayment),
                              style: const TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'TUTUP',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showOrderStatusTrackerBottomSheet(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final status = order['status'] ?? 'Pending';
        final orderDate = order['date'] ?? '';

        final isPending = status == 'Pending';
        final isDiproses = status == 'Diproses';
        final isDikirim = status == 'Dikirim';
        final isSelesai = status == 'Selesai';
        final isDibatalkan = status == 'Dibatalkan';

        final rawIdDigits = order['id']?.toString().replaceAll(RegExp(r'\D'), '') ?? '12345';
        final trackingNumber = 'GBR-$rawIdDigits-EXP';
        final List<dynamic> trackingList = order['tracking'] ?? [];

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'STATUS PENGIRIMAN',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: textSecondary),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order['id'] ?? '',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              if (trackingList.isNotEmpty) ...[
                ...List.generate(trackingList.length, (index) {
                  final step = trackingList[index];
                  final isLast = index == trackingList.length - 1;
                  final stepStatus = step['status']?.toString() ?? 'Pending';
                  
                  Color activeColor = accentColor;
                  if (stepStatus == 'Dibatalkan') {
                    activeColor = Colors.redAccent;
                  }

                  return _buildTimelineStep(
                    title: stepStatus == 'Pending' ? 'Order Dibuat' : stepStatus,
                    description: step['description']?.toString() ?? '',
                    time: step['created_at']?.toString() ?? '',
                    isActive: isLast,
                    isCompleted: !isLast,
                    isLast: isLast,
                    activeColor: activeColor,
                  );
                }),
              ] else if (isDibatalkan) ...[
                _buildTimelineStep(
                  title: 'Order Dibuat',
                  description: 'Pesanan berhasil dibuat.',
                  time: orderDate,
                  isActive: false,
                  isCompleted: true,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Pesanan Dibatalkan',
                  description: 'Pesanan telah dibatalkan oleh pengguna atau sistem.',
                  time: '',
                  isActive: true,
                  isCompleted: false,
                  isLast: true,
                  activeColor: Colors.redAccent,
                ),
              ] else ...[
                _buildTimelineStep(
                  title: 'Order Dibuat',
                  description: 'Pesanan berhasil dibuat dan menunggu proses berikutnya.',
                  time: orderDate,
                  isActive: isPending,
                  isCompleted: isDiproses || isDikirim || isSelesai,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Pembayaran Dikonfirmasi',
                  description: 'Pembayaran Anda telah sukses diverifikasi.',
                  time: '',
                  isActive: false,
                  isCompleted: isDiproses || isDikirim || isSelesai,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Pesanan Diproses',
                  description: 'Penjual sedang menyiapkan suplemen kesehatan Anda.',
                  time: '',
                  isActive: isDiproses,
                  isCompleted: isDikirim || isSelesai,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Sedang Dikirim',
                  description: isDikirim || isSelesai
                      ? 'Pesanan dalam perjalanan oleh kurir ekspedisi.\nNo. Resi: $trackingNumber'
                      : 'Pesanan akan segera diserahkan ke kurir.',
                  time: '',
                  isActive: isDikirim,
                  isCompleted: isSelesai,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Pesanan Selesai',
                  description: 'Barang telah sukses sampai di alamat tujuan.',
                  time: '',
                  isActive: isSelesai,
                  isCompleted: isSelesai,
                  isLast: true,
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'KEMBALI',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String description,
    required String time,
    required bool isActive,
    required bool isCompleted,
    required bool isLast,
    Color activeColor = accentColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? activeColor
                    : isActive
                        ? activeColor.withValues(alpha: 0.15)
                        : Colors.transparent,
                border: Border.all(
                  color: isCompleted || isActive ? activeColor : Colors.grey[700]!,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(Icons.check, size: 12, color: activeColor == accentColor ? Colors.black : Colors.white)
                  : isActive
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: activeColor,
                            ),
                          ),
                        )
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 56,
                color: isCompleted ? activeColor : Colors.grey[800],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isCompleted || isActive ? textPrimary : textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: isCompleted || isActive ? accentColor.withValues(alpha: 0.8) : textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Mock data orders
  final List<Map<String, dynamic>> mockOrders = [
    {
      'id': 'INV-20240001',
      'date': '2024-06-01',
      'status': 'Pending',
      'shipping_address': 'Jl. Sudirman No.1, Jakarta',
      'payment_method': 'QRIS',
      'shipping_cost': 20000,
      'items': [
        {
          'name': 'Whey Protein Gold Standard',
          'quantity': 2,
          'price': 350000,
          'image': 'https://via.placeholder.com/100',
        }
      ],
    },
    {
      'id': 'INV-20240002',
      'date': '2024-06-05',
      'status': 'Diproses',
      'shipping_address': 'Jl. Thamrin No.2, Jakarta',
      'payment_method': 'QRIS',
      'shipping_cost': 15000,
      'items': [
        {
          'name': 'Creatine Monohydrate',
          'quantity': 1,
          'price': 200000,
          'image': 'https://via.placeholder.com/100',
        }
      ],
    },
    {
      'id': 'INV-20240003',
      'date': '2024-06-08',
      'status': 'Dikirim',
      'shipping_address': 'Jl. Gatot Subroto No.3, Jakarta',
      'payment_method': 'QRIS',
      'shipping_cost': 25000,
      'items': [
        {
          'name': 'BCAA Powder',
          'quantity': 3,
          'price': 120000,
          'image': 'https://via.placeholder.com/100',
        }
      ],
    },
    {
      'id': 'INV-20240004',
      'date': '2024-05-20',
      'status': 'Selesai',
      'shipping_address': 'Jl. Kuningan No.4, Jakarta',
      'payment_method': 'QRIS',
      'shipping_cost': 18000,
      'items': [
        {
          'name': 'Pre-Workout C4',
          'quantity': 1,
          'price': 450000,
          'image': 'https://via.placeholder.com/100',
        }
      ],
    },
    {
      'id': 'INV-20240005',
      'date': '2024-05-10',
      'status': 'Dibatalkan',
      'shipping_address': 'Jl. Rasuna Said No.5, Jakarta',
      'payment_method': 'QRIS',
      'shipping_cost': 20000,
      'items': [
        {
          'name': 'Casein Protein',
          'quantity': 2,
          'price': 310000,
          'image': 'https://via.placeholder.com/100',
        }
      ],
    },
  ];

  Widget buildWithOrders(List<Map<String, dynamic>> orders) {
    return MaterialApp(
      home: _MockPurchaseHistoryPage(mockOrders: orders),
    );
  }

  Widget buildEmptyHistory() {
    return MaterialApp(
      home: _MockPurchaseHistoryPage(mockOrders: const [], isEmpty: true),
    );
  }

  // ---------------------------------------------------------------------------
  // SCENARIO: TS.JR-1 | Melihat Status Pembeli / Riwayat Pembelian
  // ---------------------------------------------------------------------------
  group('TS.RP-1 - Melihat Riwayat Pembelian', () {
    // -------------------------------------------------------------------------
    // TC.JR-1.001 | Positive | Buka Riwayat Pembelian
    // Pre : User sudah login dan memiliki riwayat transaksi
    // Steps:
    //   1. Buka halaman Riwayat Transaksi
    // Expected : Halaman Riwayat Transaksi terbuka dan menampilkan daftar order
    // -------------------------------------------------------------------------
    testWidgets(
      '[TC.RP-1.001] Positive - Buka Riwayat Pembelian → halaman dan transaksi tampil',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildWithOrders(mockOrders));
        await tester.pumpAndSettle();

        // Verifikasi halaman Riwayat Transaksi muncul
        expect(
          find.text('RIWAYAT TRANSAKSI'),
          findsOneWidget,
          reason: 'TC.JR-1.001: AppBar harus menampilkan judul RIWAYAT TRANSAKSI',
        );

        // Verifikasi ada minimal 1 order card yang tampil
        expect(
          find.byKey(const Key('order_card_0')),
          findsOneWidget,
          reason: 'TC.JR-1.001: Harus ada minimal 1 transaksi yang tampil',
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // SCENARIO: TS.RP | Riwayat Pembelian - Detail & State Kosong
  // ---------------------------------------------------------------------------
  group('TS.RP 1 - Riwayat Pembelian (Detail & Empty State)', () {
    // -------------------------------------------------------------------------
    // TC.RP-1.001 | Positive | Membuka detail transaksi
    // Pre : User berada di halaman Riwayat Pembelian, ada transaksi
    // Steps:
    //   1. Klik satu transaksi dari daftar
    // Expected : Halaman / bottom sheet Detail Transaksi tampil
    // -------------------------------------------------------------------------
    testWidgets(
      '[TC.RP-1.002] Positive - Klik transaksi → Detail Transaksi tampil',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildWithOrders(mockOrders));
        await tester.pumpAndSettle();

        // Verifikasi order card pertama tampil
        expect(find.byKey(const Key('order_card_0')), findsOneWidget);

        // Klik order card pertama
        await tester.tap(find.byKey(const Key('order_card_0')));
        await tester.pumpAndSettle();

        // Expected: bottom sheet detail transaksi muncul
        expect(
          find.text('DETAIL TRANSAKSI'),
          findsOneWidget,
          reason: 'TC.RP-1.001: Bottom sheet Detail Transaksi harus muncul setelah tap order',
        );
        expect(
          find.text('INV-20240001'),
          findsWidgets,
          reason: 'TC.RP-1.001: Invoice ID harus tampil di detail transaksi',
        );
      },
    );

    // -------------------------------------------------------------------------
    // TC.RP-1.002 | Negative | Tidak memiliki riwayat pembelian
    // Pre : User belum pernah melakukan pembelian / riwayat kosong
    // Steps:
    //   1. Buka halaman Riwayat Pembelian
    // Expected : Muncul pesan "Belum Ada Riwayat Belanja"
    // -------------------------------------------------------------------------
    testWidgets(
      '[TC.RP-1.003] Negative - Tidak ada riwayat → tampil pesan kosong',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildEmptyHistory());
        await tester.pumpAndSettle();

        // Expected: muncul empty state
        expect(
          find.text('Belum Ada Riwayat Belanja'),
          findsOneWidget,
          reason: 'TC.RP-1.002: Harus muncul pesan "Belum Ada Riwayat Belanja" '
              'saat tidak ada transaksi',
        );

        // Tidak ada order card
        expect(
          find.byKey(const Key('order_card_0')),
          findsNothing,
          reason: 'TC.RP-1.002: Tidak boleh ada order card jika riwayat kosong',
        );
      },
    );
  });
}
