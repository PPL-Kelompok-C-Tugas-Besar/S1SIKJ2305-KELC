import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_voucher_provider.dart';
import '../../models/voucher_model.dart';
import '../../utils/admin_colors.dart';
import 'voucher_form_screen.dart';

class ManageVouchersScreen extends StatefulWidget {
  const ManageVouchersScreen({super.key});

  @override
  State<ManageVouchersScreen> createState() => _ManageVouchersScreenState();
}

class _ManageVouchersScreenState extends State<ManageVouchersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminVoucherProvider>(context, listen: false).fetchVouchers();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    Provider.of<AdminVoucherProvider>(context, listen: false).fetchVouchers(search: query);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminVoucherProvider>(context);

    return Scaffold(
      backgroundColor: AdminColors.bgColor,
      appBar: AppBar(
        title: const Text('Kelola Voucher', style: TextStyle(color: AdminColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AdminColors.cardColor,
        iconTheme: const IconThemeData(color: AdminColors.textPrimary),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AdminColors.textPrimary),
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari kode atau nama voucher...',
                hintStyle: const TextStyle(color: AdminColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AdminColors.accentColor),
                filled: true,
                fillColor: AdminColors.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // Vouchers List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchVouchers(search: _searchQuery),
              color: AdminColors.accentColor,
              backgroundColor: AdminColors.cardColor,
              child: provider.isLoading && provider.vouchers.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AdminColors.accentColor))
                  : _buildVoucherList(context, provider),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AdminColors.accentColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VoucherFormScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildVoucherList(BuildContext context, AdminVoucherProvider provider) {
    final List<Voucher> vouchers = provider.vouchers;

    if (vouchers.isEmpty) {
      return const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 80.0, horizontal: 24.0),
            child: Column(
              children: [
                Icon(Icons.confirmation_number_outlined, size: 64, color: AdminColors.textSecondary),
                SizedBox(height: 16),
                Text(
                  'Tidak ada voucher ditemukan',
                  style: TextStyle(color: AdminColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        final voucher = vouchers[index];
        return _buildVoucherCard(context, voucher, provider);
      },
    );
  }

  Widget _buildVoucherCard(BuildContext context, Voucher voucher, AdminVoucherProvider provider) {
    final dateFormat = DateFormat('dd MMM yyyy');
    String dateRange = 'Tanpa Batasan Tanggal';
    if (voucher.startDate != null && voucher.endDate != null) {
      dateRange = '${dateFormat.format(voucher.startDate!)} - ${dateFormat.format(voucher.endDate!)}';
    } else if (voucher.endDate != null) {
      dateRange = 's.d. ${dateFormat.format(voucher.endDate!)}';
    }

    final discountText = voucher.discountType == 'percentage'
        ? '${voucher.discountValue.toStringAsFixed(0)}%'
        : 'Rp ${voucher.discountValue.toStringAsFixed(0)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AdminColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Code, Discount Badge, Switch)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AdminColors.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AdminColors.accentColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        voucher.code,
                        style: const TextStyle(
                          color: AdminColors.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        discountText,
                        style: const TextStyle(
                          color: AdminColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: voucher.isActive,
                  activeColor: AdminColors.accentColor,
                  activeTrackColor: AdminColors.accentColor.withValues(alpha: 0.3),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.white10,
                  onChanged: (value) async {
                    final body = voucher.toJson();
                    body['is_active'] = value ? 1 : 0;
                    final success = await provider.updateVoucher(voucher.id, body);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Voucher "${voucher.code}" kini ${value ? "Aktif" : "Tidak Aktif"}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Details info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.name,
                  style: const TextStyle(
                    color: AdminColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                if (voucher.description != null && voucher.description!.isNotEmpty) ...[
                  Text(
                    voucher.description!,
                    style: const TextStyle(color: AdminColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                ],
                const Divider(color: Colors.white10, height: 16),
                
                // Specifications Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Min. Belanja', style: TextStyle(color: AdminColors.textSecondary, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          'Rp ${voucher.minimumPurchase.toStringAsFixed(0)}',
                          style: const TextStyle(color: AdminColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (voucher.discountType == 'percentage')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Maks. Potongan', style: TextStyle(color: AdminColors.textSecondary, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            voucher.maxDiscount > 0
                                ? 'Rp ${voucher.maxDiscount.toStringAsFixed(0)}'
                                : 'Tanpa batas',
                            style: const TextStyle(color: AdminColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Masa Berlaku', style: TextStyle(color: AdminColors.textSecondary, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          dateRange,
                          style: const TextStyle(color: AdminColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.blueAccent),
                  tooltip: 'Detail',
                  onPressed: () => _showDetailDialog(context, voucher),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.amber),
                  tooltip: 'Edit',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VoucherFormScreen(voucher: voucher),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Hapus',
                  onPressed: () => _confirmDelete(context, voucher, provider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, Voucher voucher) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    final discountText = voucher.discountType == 'percentage'
        ? '${voucher.discountValue.toStringAsFixed(0)}%'
        : 'Rp ${voucher.discountValue.toStringAsFixed(0)}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.confirmation_number_outlined, color: AdminColors.accentColor),
            const SizedBox(width: 10),
            Text(voucher.code, style: const TextStyle(color: AdminColors.textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nama', voucher.name),
            _buildDetailRow('Deskripsi', voucher.description ?? '-'),
            _buildDetailRow('Jenis Diskon', voucher.discountType == 'percentage' ? 'Persentase' : 'Nominal Tetap'),
            _buildDetailRow('Nilai Diskon', discountText),
            _buildDetailRow('Min. Belanja', 'Rp ${voucher.minimumPurchase.toStringAsFixed(0)}'),
            if (voucher.discountType == 'percentage')
              _buildDetailRow('Maks. Potongan', voucher.maxDiscount > 0 ? 'Rp ${voucher.maxDiscount.toStringAsFixed(0)}' : 'Tanpa batas'),
            _buildDetailRow(
              'Mulai',
              voucher.startDate != null ? dateFormat.format(voucher.startDate!) : '-',
            ),
            _buildDetailRow(
              'Berakhir',
              voucher.endDate != null ? dateFormat.format(voucher.endDate!) : '-',
            ),
            _buildDetailRow('Status', voucher.isActive ? 'Aktif' : 'Tidak Aktif'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: AdminColors.accentColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AdminColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Voucher voucher, AdminVoucherProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Konfirmasi Hapus', style: TextStyle(color: AdminColors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(
          'Apakah Anda yakin ingin menghapus voucher "${voucher.code}"?',
          style: const TextStyle(color: AdminColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AdminColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final success = await provider.deleteVoucher(voucher.id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voucher berhasil dihapus'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
