import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';

class AppColors {
  static const Color bgColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF292929);
  static const Color accentColor = Color(0xFFCCFF00);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);
}

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Pending', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'];

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('http://localhost:3000/checkout/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data'] ?? [];
          setState(() {
            _orders = list.map((item) => Map<String, dynamic>.from(item)).toList();
            _isLoading = false;
          });
          return;
        }
      }
      setState(() {
        _errorMessage = 'Gagal mengambil data dari server';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan koneksi internet';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 'Semua') {
      return _orders;
    }
    return _orders.where((order) => order['status'] == _selectedFilter).toList();
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
        return AppColors.accentColor;
      case 'Selesai':
        return AppColors.accentColor;
      case 'Dibatalkan':
        return Colors.redAccent;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

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
              'BELANJA',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'RIWAYAT TRANSAKSI',
              style: TextStyle(
                color: AppColors.textPrimary,
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
                        color: isSelected ? Colors.black : AppColors.textPrimary,
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
                    selectedColor: AppColors.accentColor,
                    backgroundColor: AppColors.cardColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.accentColor : Colors.white.withValues(alpha: 0.05),
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.accentColor),
                    )
                  : _errorMessage.isNotEmpty && _orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.redAccent,
                                size: 56,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _fetchOrders,
                                icon: const Icon(Icons.refresh_rounded, color: Colors.black),
                                label: const Text('COBA LAGI', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentColor,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        )
                      : orders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_outlined,
                                      color: AppColors.textSecondary,
                                      size: 56,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Belum Ada Riwayat Belanja',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Status filter: $_selectedFilter.\nYuk, belanja suplemen kesehatan Anda sekarang!',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentColor,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: const Text(
                                      'BELANJA SEKARANG',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
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
                            color: AppColors.cardColor,
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
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            order['date'],
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
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
                                          color: AppColors.bgColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: firstItem['image'].toString().startsWith('http')
                                              ? Image.network(
                                                  firstItem['image'],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => const Center(
                                                    child: Icon(Icons.fitness_center, color: AppColors.textSecondary, size: 20),
                                                  ),
                                                )
                                              : Image.asset(
                                                  firstItem['image'],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => const Center(
                                                    child: Icon(Icons.fitness_center, color: AppColors.textSecondary, size: 20),
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
                                                color: AppColors.textPrimary,
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
                                                color: AppColors.textSecondary,
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
                                        color: AppColors.textSecondary,
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
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        _formatRupiah(totalPayment),
                                        style: const TextStyle(
                                          color: AppColors.accentColor,
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
      backgroundColor: AppColors.bgColor,
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
                        style: TextStyle(
                          color: AppColors.textPrimary,
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
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Dibuat pada: ${order['date']}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showOrderStatusTrackerBottomSheet(context, order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentColor,
                        side: const BorderSide(color: AppColors.accentColor, width: 1.5),
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
                      color: AppColors.textSecondary,
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
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.accentColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            order['shipping_address'],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
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
                      color: AppColors.textSecondary,
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
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.bgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: item['image'].toString().startsWith('http')
                                    ? Image.network(
                                        item['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(Icons.fitness_center, color: AppColors.textSecondary, size: 20),
                                        ),
                                      )
                                    : Image.asset(
                                        item['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(Icons.fitness_center, color: AppColors.textSecondary, size: 20),
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
                                      color: AppColors.textPrimary,
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
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        _formatRupiah((item['price'] as num).toInt() * (item['quantity'] as num).toInt()),
                                        style: const TextStyle(
                                          color: AppColors.accentColor,
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
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Metode Pembayaran',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            Text(
                              order['payment_method'],
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            Text(
                              _formatRupiah(subtotal),
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ongkos Kirim',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            Text(
                              _formatRupiah((order['shipping_cost'] as num).toInt()),
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
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
                              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              _formatRupiah(totalPayment),
                              style: const TextStyle(color: AppColors.accentColor, fontWeight: FontWeight.w900, fontSize: 16),
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
                        backgroundColor: AppColors.accentColor,
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
      backgroundColor: AppColors.bgColor,
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

        // Generate deterministic tracking number using numerical digits of order id
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
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
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
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              if (trackingList.isNotEmpty) ...[
                ...List.generate(trackingList.length, (index) {
                  final step = trackingList[index];
                  final isLast = index == trackingList.length - 1;
                  final stepStatus = step['status']?.toString() ?? 'Pending';
                  
                  Color activeColor = AppColors.accentColor;
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
                    backgroundColor: AppColors.accentColor,
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
    Color activeColor = AppColors.accentColor,
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
                  ? Icon(Icons.check, size: 12, color: activeColor == AppColors.accentColor ? Colors.black : Colors.white)
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
                  color: isCompleted || isActive ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: isCompleted || isActive ? AppColors.accentColor.withValues(alpha: 0.8) : AppColors.textSecondary,
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
