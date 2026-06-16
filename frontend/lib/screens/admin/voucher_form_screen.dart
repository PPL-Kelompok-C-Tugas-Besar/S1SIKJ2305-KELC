import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/voucher_model.dart';
import '../../providers/admin_voucher_provider.dart';
import '../../utils/admin_colors.dart';

class VoucherFormScreen extends StatefulWidget {
  final Voucher? voucher;

  const VoucherFormScreen({super.key, this.voucher});

  @override
  State<VoucherFormScreen> createState() => _VoucherFormScreenState();
}

class _VoucherFormScreenState extends State<VoucherFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _codeCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _valueCtrl;
  late TextEditingController _minPurchaseCtrl;
  late TextEditingController _maxDiscountCtrl;

  String _discountType = 'fixed'; // 'fixed' or 'percentage'
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final v = widget.voucher;

    _nameCtrl = TextEditingController(text: v?.name ?? '');
    _codeCtrl = TextEditingController(text: v?.code ?? '');
    _descCtrl = TextEditingController(text: v?.description ?? '');
    _valueCtrl = TextEditingController(text: v?.discountValue != null ? v!.discountValue.toStringAsFixed(0) : '');
    _minPurchaseCtrl = TextEditingController(text: v?.minimumPurchase != null ? v!.minimumPurchase.toStringAsFixed(0) : '');
    _maxDiscountCtrl = TextEditingController(text: v?.maxDiscount != null ? v!.maxDiscount.toStringAsFixed(0) : '');

    if (v != null) {
      _discountType = v.discountType;
      _startDate = v.startDate;
      _endDate = v.endDate;
      _isActive = v.isActive;
    }

    // Add listeners to rebuild for preview changes
    _nameCtrl.addListener(_updateState);
    _codeCtrl.addListener(_updateState);
    _descCtrl.addListener(_updateState);
    _valueCtrl.addListener(_updateState);
    _minPurchaseCtrl.addListener(_updateState);
    _maxDiscountCtrl.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_updateState);
    _codeCtrl.removeListener(_updateState);
    _descCtrl.removeListener(_updateState);
    _valueCtrl.removeListener(_updateState);
    _minPurchaseCtrl.removeListener(_updateState);
    _maxDiscountCtrl.removeListener(_updateState);

    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _valueCtrl.dispose();
    _minPurchaseCtrl.dispose();
    _maxDiscountCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 7)));
    
    final DateTime firstDate = DateTime(2025);
    final DateTime lastDate = DateTime(2035);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AdminColors.accentColor,
              onPrimary: Colors.black,
              surface: AdminColors.cardColor,
              onSurface: AdminColors.textPrimary,
            ),
            dialogBackgroundColor: AdminColors.bgColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // If end date is before new start date, shift/reset end date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate!.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Date validations
    if (_startDate != null && _endDate != null) {
      if (_endDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal berakhir tidak boleh sebelum tanggal mulai!'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    final double discountVal = double.tryParse(_valueCtrl.text) ?? 0.0;
    if (discountVal < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nilai diskon tidak boleh kurang dari 0!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final double minPurchase = double.tryParse(_minPurchaseCtrl.text) ?? 0.0;
    final double maxDiscount = double.tryParse(_maxDiscountCtrl.text) ?? 0.0;

    final body = {
      'code': _codeCtrl.text.trim().toUpperCase(),
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'discount_type': _discountType,
      'discount_value': discountVal,
      'minimum_purchase': minPurchase,
      'max_discount': _discountType == 'percentage' ? maxDiscount : 0.0,
      'start_date': _startDate?.toIso8601String(),
      'end_date': _endDate?.toIso8601String(),
      'is_active': _isActive ? 1 : 0,
    };

    final provider = Provider.of<AdminVoucherProvider>(context, listen: false);
    bool success;

    if (widget.voucher != null) {
      success = await provider.updateVoucher(widget.voucher!.id, body);
    } else {
      success = await provider.createVoucher(body);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.voucher != null ? 'Voucher berhasil diperbarui' : 'Voucher berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Gagal menyimpan voucher'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.voucher != null;

    return Scaffold(
      backgroundColor: AdminColors.bgColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Voucher' : 'Tambah Voucher', style: const TextStyle(color: AdminColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AdminColors.cardColor,
        iconTheme: const IconThemeData(color: AdminColors.textPrimary),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Informasi Voucher'),
                    const SizedBox(height: 12),
                    
                    // Name
                    _buildTextField(
                      label: 'Nama Voucher *',
                      controller: _nameCtrl,
                      hint: 'Contoh: Diskon Member Baru',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Nama voucher wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Code
                    _buildTextField(
                      label: 'Kode Voucher *',
                      controller: _codeCtrl,
                      hint: 'Contoh: NEW50',
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      ],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Kode voucher wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Description
                    _buildTextField(
                      label: 'Deskripsi Voucher',
                      controller: _descCtrl,
                      hint: 'Contoh: Potongan khusus bagi pendaftaran member pertama kali.',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Pengaturan Diskon'),
                    const SizedBox(height: 12),

                    // Discount Type Dropdown
                    _buildDropdownField(
                      label: 'Jenis Diskon',
                      value: _discountType,
                      items: const [
                        DropdownMenuItem(value: 'fixed', child: Text('Nominal (Rp)', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'percentage', child: Text('Persentase (%)', style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _discountType = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Discount Value
                    _buildTextField(
                      label: 'Nilai Diskon *',
                      controller: _valueCtrl,
                      hint: _discountType == 'percentage' ? 'Contoh: 10' : 'Contoh: 50000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Nilai diskon wajib diisi';
                        final doubleVal = double.tryParse(val);
                        if (doubleVal == null || doubleVal < 0) return 'Nilai diskon tidak boleh kurang dari 0';
                        if (_discountType == 'percentage' && doubleVal > 100) return 'Nilai persentase tidak boleh > 100';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Minimum Purchase
                    _buildTextField(
                      label: 'Minimal Pembelian',
                      controller: _minPurchaseCtrl,
                      hint: 'Contoh: 100000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 14),

                    // Maximum Discount (Only shows/applies for percentage)
                    if (_discountType == 'percentage') ...[
                      _buildTextField(
                        label: 'Maksimal Potongan',
                        controller: _maxDiscountCtrl,
                        hint: 'Contoh: 50000',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 14),
                    ],
                    const SizedBox(height: 24),

                    _buildSectionTitle('Durasi & Status'),
                    const SizedBox(height: 12),

                    // Date Selectors
                    Row(
                      children: [
                        Expanded(
                          child: _buildDatePickerButton(
                            label: 'Tanggal Mulai',
                            selectedDate: _startDate,
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDatePickerButton(
                            label: 'Tanggal Berakhir',
                            selectedDate: _endDate,
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Status Switch
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AdminColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status Voucher Aktif',
                            style: TextStyle(color: AdminColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Switch(
                            value: _isActive,
                            activeColor: AdminColors.accentColor,
                            onChanged: (val) {
                              setState(() {
                                _isActive = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Voucher Preview'),
              const SizedBox(height: 12),
              
              // Real-time Preview Card
              _buildRealtimePreviewCard(),

              const SizedBox(height: 36),

              // Save Button
              Consumer<AdminVoucherProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.accentColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      onPressed: provider.isLoading ? null : _submit,
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              isEdit ? 'PERBARUI VOUCHER' : 'SIMPAN VOUCHER',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AdminColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AdminColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(color: AdminColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            filled: true,
            fillColor: AdminColors.cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AdminColors.accentColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AdminColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AdminColors.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              dropdownColor: AdminColors.cardColor,
              icon: const Icon(Icons.arrow_drop_down, color: AdminColors.accentColor),
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerButton({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    final formattedDate = selectedDate != null
        ? DateFormat('dd MMM yyyy').format(selectedDate)
        : 'Pilih Tanggal';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AdminColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AdminColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: selectedDate != null ? AdminColors.textPrimary : Colors.white24,
                    fontSize: 14,
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, color: AdminColors.accentColor, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealtimePreviewCard() {
    final code = _codeCtrl.text.isNotEmpty ? _codeCtrl.text.toUpperCase() : 'CODE';
    
    // Value text
    String discountDesc = 'Diskon -';
    if (_valueCtrl.text.isNotEmpty) {
      final doubleVal = double.tryParse(_valueCtrl.text) ?? 0.0;
      discountDesc = _discountType == 'percentage'
          ? 'Diskon ${doubleVal.toStringAsFixed(0)}%'
          : 'Diskon Rp ${doubleVal.toStringAsFixed(0)}';
    }

    // Min purchase text
    String minPurchaseText = 'Minimal Belanja: Rp 0';
    if (_minPurchaseCtrl.text.isNotEmpty) {
      final doubleMin = double.tryParse(_minPurchaseCtrl.text) ?? 0.0;
      minPurchaseText = 'Minimal Belanja: Rp ${doubleMin.toStringAsFixed(0)}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.accentColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AdminColors.accentColor.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          // Left Ticket stub design icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _discountType == 'percentage' ? Icons.percent : Icons.confirmation_number_outlined,
              color: AdminColors.accentColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          
          // Main Preview Data
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
                        code,
                        style: const TextStyle(
                          color: AdminColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Nama Voucher',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AdminColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  discountDesc,
                  style: const TextStyle(
                    color: AdminColors.accentColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  minPurchaseText,
                  style: const TextStyle(color: AdminColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper text formatter to automatically capitalize input
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
