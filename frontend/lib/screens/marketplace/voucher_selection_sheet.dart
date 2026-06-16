import 'package:flutter/material.dart';
import '../../models/voucher_model.dart';
import '../../services/supplement_service.dart';
import '../../utils/palette.dart';

class VoucherSelectionSheet extends StatefulWidget {
  final double currentSubtotal;
  final Voucher? selectedVoucher;

  const VoucherSelectionSheet({
    super.key,
    required this.currentSubtotal,
    this.selectedVoucher,
  });

  @override
  State<VoucherSelectionSheet> createState() => _VoucherSelectionSheetState();
}

class _VoucherSelectionSheetState extends State<VoucherSelectionSheet> {
  final SupplementService _supplementService = SupplementService();
  List<Voucher> _vouchers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    print('VoucherSelectionSheet: _loadVouchers called with subtotal: ${widget.currentSubtotal}');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _supplementService.getVouchers();
    print('VoucherSelectionSheet: getVouchers result success=${result['success']}');
    if (!result['success']) {
      print('VoucherSelectionSheet: getVouchers error message: ${result['message']}');
    } else {
      print('VoucherSelectionSheet: getVouchers found ${result['data']?.length} vouchers');
    }

    if (mounted) {
      if (result['success']) {
        setState(() {
          _vouchers = result['data'];
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pilih Voucher Diskon',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (widget.selectedVoucher != null)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, null); // Return null to clear applied voucher
                  },
                  child: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: _isLoading
                ? const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(color: kAccent),
                  ))
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                        ),
                      )
                    : _vouchers.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Text(
                                'Tidak ada voucher tersedia saat ini.',
                                style: TextStyle(color: kTextMuted),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: _vouchers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final voucher = _vouchers[index];
                              final isSelectable = widget.currentSubtotal >= voucher.minimumPurchase;
                              final isCurrentlySelected = widget.selectedVoucher?.code == voucher.code;

                              return Opacity(
                                opacity: isSelectable ? 1.0 : 0.45,
                                child: InkWell(
                                  onTap: isSelectable
                                      ? () {
                                          Navigator.pop(context, voucher);
                                        }
                                      : null,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: kBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isCurrentlySelected
                                            ? kAccent
                                            : Colors.white.withValues(alpha: 0.05),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Left Discount Badge
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isSelectable
                                                ? kAccent.withValues(alpha: 0.15)
                                                : Colors.white10,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            voucher.discountType == 'percentage'
                                                ? Icons.percent
                                                : Icons.confirmation_number_outlined,
                                            color: isSelectable ? kAccent : kTextMuted,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        
                                        // Voucher Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white12,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      voucher.code,
                                                      style: const TextStyle(
                                                        color: kTextPrimary,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      voucher.name,
                                                      style: const TextStyle(
                                                        color: kTextPrimary,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                voucher.description ?? '',
                                                style: const TextStyle(color: kTextMuted, fontSize: 11),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Min. Belanja: Rp ${voucher.minimumPurchase.toStringAsFixed(0)}',
                                                    style: TextStyle(
                                                      color: isSelectable ? kTextMuted : Colors.redAccent,
                                                      fontSize: 11,
                                                      fontWeight: isSelectable ? FontWeight.normal : FontWeight.bold,
                                                    ),
                                                  ),
                                                   if (voucher.discountType == 'percentage' && voucher.maxDiscount > 0) ...[
                                                     const SizedBox(width: 8),
                                                     Text(
                                                       '• Maks: Rp ${voucher.maxDiscount.toStringAsFixed(0)}',
                                                      style: const TextStyle(color: kTextMuted, fontSize: 11),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Selection Radio/Indicator
                                        if (isCurrentlySelected)
                                          const Icon(Icons.check_circle, color: kAccent)
                                        else if (!isSelectable)
                                          const Icon(Icons.lock_outline, color: kTextMuted, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
