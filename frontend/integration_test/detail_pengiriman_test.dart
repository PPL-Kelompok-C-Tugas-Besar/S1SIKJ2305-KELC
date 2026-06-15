// =============================================================================
// SCENARIO ID : S.DP-1
// Scenario    : Input Detail Pengiriman Valid
// Test Cases  : TC.DP-1.001 s/d TC.DP-1.004
// Feature     : Form tambah alamat pengiriman di halaman Checkout
// Type        : Integration Test (FT - Functional Test)
// =============================================================================
//
// CATATAN IMPLEMENTASI:
// Mock widget ini meniru tampilan & alur asli CheckoutPage:
//   - Dark theme (0xFF1A1A1A / 0xFF292929 / 0xFFCCFF00)
//   - Tombol area alamat → bottom sheet "PILIH ALAMAT"
//   - Tombol "TAMBAH ALAMAT BARU" → AlertDialog dengan form
//   - Validasi & FilteringTextInputFormatter sama persis dengan kode asli
//   - Tidak bergantung ke flutter_secure_storage / network / AuthService
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Konstanta warna — sama persis dengan AppColors di checkout_ecommerce.dart
// ─────────────────────────────────────────────────────────────────────────────
class _AppColors {
  static const Color bgColor       = Color(0xFF1A1A1A);
  static const Color cardColor     = Color(0xFF292929);
  static const Color accentColor   = Color(0xFFCCFF00);
  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: InputDecoration — sama dengan _buildInputDecoration() di CheckoutPage
// ─────────────────────────────────────────────────────────────────────────────
InputDecoration _buildInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: _AppColors.textSecondary),
    filled: true,
    fillColor: Color(0xFF3A3A3A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _AppColors.accentColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    errorStyle: const TextStyle(color: Colors.redAccent),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock CheckoutPage — meniru tampilan & alur asli tanpa network/secure storage
// ─────────────────────────────────────────────────────────────────────────────
class _MockCheckoutPage extends StatefulWidget {
  const _MockCheckoutPage();

  @override
  State<_MockCheckoutPage> createState() => _MockCheckoutPageState();
}

class _MockCheckoutPageState extends State<_MockCheckoutPage> {
  bool isOrdering = false;
  String _selectedPayment = 'QRIS';

  int _selectedAddressIndex = 0;
  bool _isLoadingAddresses = false;
  bool _isManagingAddresses = false;

  final List<Map<String, String>> _addresses = [];

  Map<String, String>? get _currentAddress {
    if (_addresses.isEmpty ||
        _selectedAddressIndex < 0 ||
        _selectedAddressIndex >= _addresses.length) {
      return null;
    }
    return _addresses[_selectedAddressIndex];
  }

  final List<Map<String, dynamic>> _selectedItems = [
    {
      'name': 'Whey Protein Gold Standard',
      'price': 350000,
      'quantity': 2,
      'image': 'assets/whey.png',
    }
  ];
  final int _subtotal = 700000;
  final int _shippingCost = 15000;

  int get totalCost => _subtotal + _shippingCost;

  String formatRupiah(int number) {
    String numStr = number.toString();
    String result = '';
    for (int i = 0; i < numStr.length; i++) {
      if (i > 0 && (numStr.length - i) % 3 == 0) {
        result += '.';
      }
      result += numStr[i];
    }
    return 'Rp $result';
  }

  void _showAddressSelectionBottomSheet(BuildContext context) {
    _isManagingAddresses = false; // Reset to select mode when opening
    showModalBottomSheet(
      context: context,
      backgroundColor: _AppColors.bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
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
                        'PILIH ALAMAT',
                        style: TextStyle(
                          color: _AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _isManagingAddresses = !_isManagingAddresses;
                          });
                        },
                        child: Text(
                          _isManagingAddresses ? 'Selesai' : 'Kelola',
                          style: const TextStyle(
                            color: _AppColors.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: _addresses.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.location_off_rounded,
                                    color: _AppColors.textSecondary, size: 48),
                                SizedBox(height: 12),
                                Text(
                                  'Belum ada alamat pengiriman',
                                  style: TextStyle(
                                    color: _AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Silakan tambahkan alamat baru di bawah.',
                                  style: TextStyle(
                                    color: _AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: _addresses.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final address = _addresses[index];
                              final isSelected = _selectedAddressIndex == index;
                              final isDefault = address['isDefault'] == 'true';
                              return GestureDetector(
                                key: Key('addr_card_$index'),
                                onTap: _isManagingAddresses
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedAddressIndex = index;
                                        });
                                        setModalState(() {});
                                        Navigator.pop(context);
                                      },
                                child: Container(
                                  height: 130,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _AppColors.cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: !_isManagingAddresses && isSelected
                                          ? _AppColors.accentColor
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (!_isManagingAddresses) ...[
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? _AppColors.accentColor
                                                  : _AppColors.textSecondary,
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? Center(
                                                  child: Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: const BoxDecoration(
                                                      color: _AppColors.accentColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                      ],
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  address['name']!,
                                                  style: const TextStyle(
                                                    color: _AppColors.textPrimary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                if (isDefault) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: _AppColors.accentColor
                                                          .withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(
                                                          color: _AppColors.accentColor,
                                                          width: 1),
                                                    ),
                                                    child: const Text(
                                                      'Utama',
                                                      style: TextStyle(
                                                        color: _AppColors.accentColor,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              address['phone']!,
                                              style: const TextStyle(
                                                color: _AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${address['address']!}\n${address['city']!}, ${address['postalCode']!}',
                                              style: const TextStyle(
                                                color: _AppColors.textSecondary,
                                                fontSize: 12,
                                                height: 1.4,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_isManagingAddresses) ...[
                                        IconButton(
                                          onPressed: () {
                                            _showAddAddressDialog(context,
                                                existingAddress: address, onAdd: () {
                                              setModalState(() {});
                                            });
                                          },
                                          icon: const Icon(Icons.edit_outlined,
                                              color: _AppColors.accentColor, size: 20),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          splashRadius: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _addresses.removeAt(index);
                                              if (_selectedAddressIndex == index) {
                                                if (_selectedAddressIndex >=
                                                    _addresses.length) {
                                                  _selectedAddressIndex =
                                                      _addresses.length - 1;
                                                }
                                              } else if (_selectedAddressIndex > index) {
                                                _selectedAddressIndex--;
                                              }
                                              if (_selectedAddressIndex < 0) {
                                                _selectedAddressIndex = 0;
                                              }
                                            });
                                            setModalState(() {});
                                          },
                                          icon: const Icon(Icons.delete_outline_rounded,
                                              color: Colors.redAccent, size: 20),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          splashRadius: 20,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('btn_tambah_alamat'),
                      onPressed: () {
                        _showAddAddressDialog(context, onAdd: () {
                          setModalState(() {});
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _AppColors.accentColor,
                        side: const BorderSide(color: _AppColors.accentColor, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(
                        'TAMBAH ALAMAT BARU',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
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

  void _showAddAddressDialog(BuildContext context,
      {Map<String, String>? existingAddress, required VoidCallback onAdd}) {
    final isEditing = existingAddress != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: isEditing ? existingAddress['name'] : '');
    final phoneController = TextEditingController(text: isEditing ? existingAddress['phone'] : '');
    final addressController =
        TextEditingController(text: isEditing ? existingAddress['address'] : '');
    final cityController = TextEditingController(text: isEditing ? existingAddress['city'] : '');
    final postalCodeController =
        TextEditingController(text: isEditing ? existingAddress['postalCode'] : '');

    bool makeDefault = isEditing ? (existingAddress['isDefault'] == 'true') : false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: _AppColors.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                isEditing ? 'Edit Alamat' : 'Tambah Alamat Baru',
                style: const TextStyle(
                  color: _AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        key: const Key('field_nama'),
                        controller: nameController,
                        style: const TextStyle(color: _AppColors.textPrimary),
                        decoration: _buildInputDecoration('Nama Penerima'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Nama penerima wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('field_telepon'),
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(color: _AppColors.textPrimary),
                        decoration: _buildInputDecoration('Nomor Telepon'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Nomor telepon wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('field_alamat'),
                        controller: addressController,
                        maxLines: 3,
                        style: const TextStyle(color: _AppColors.textPrimary),
                        decoration: _buildInputDecoration('Alamat Lengkap'),
                        validator: (v) => v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              key: const Key('field_kota'),
                              controller: cityController,
                              style: const TextStyle(color: _AppColors.textPrimary),
                              decoration: _buildInputDecoration('Kota'),
                              validator: (v) => v == null || v.isEmpty ? 'Kota wajib diisi' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              key: const Key('field_kode_pos'),
                              controller: postalCodeController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: const TextStyle(color: _AppColors.textPrimary),
                              decoration: _buildInputDecoration('Kode Pos'),
                              validator: (v) => v == null || v.isEmpty ? 'Kode pos wajib' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            makeDefault = !makeDefault;
                          });
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              key: const Key('chk_default'),
                              value: makeDefault,
                              activeColor: _AppColors.accentColor,
                              checkColor: Colors.black,
                              onChanged: (v) {
                                setDialogState(() {
                                  makeDefault = v ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Jadikan Alamat Utama',
                              style: TextStyle(color: _AppColors.textPrimary, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal', style: TextStyle(color: _AppColors.textSecondary)),
                ),
                ElevatedButton(
                  key: const Key('btn_simpan'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        if (isEditing) {
                          final idx = _addresses.indexWhere((element) => element['id'] == existingAddress['id']);
                          if (idx != -1) {
                            _addresses[idx] = {
                              'id': existingAddress['id']!,
                              'name': nameController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'address': addressController.text.trim(),
                              'city': cityController.text.trim(),
                              'postalCode': postalCodeController.text.trim(),
                              'isDefault': makeDefault.toString(),
                            };
                          }
                        } else {
                          _addresses.add({
                            'id': DateTime.now().millisecondsSinceEpoch.toString(),
                            'name': nameController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'address': addressController.text.trim(),
                            'city': cityController.text.trim(),
                            'postalCode': postalCodeController.text.trim(),
                            'isDefault': makeDefault.toString(),
                          });
                          _selectedAddressIndex = _addresses.length - 1;
                        }
                      });
                      onAdd();
                      Navigator.pop(ctx);
                      if (!isEditing) {
                        Navigator.pop(context); // Close bottom sheet on new address addition
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _AppColors.accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _AppColors.textPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'SHOP',
              style: TextStyle(
                color: _AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'CHECKOUT',
              style: TextStyle(
                color: _AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 24,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Order Items ──────────────────────────────
                    _buildSectionLabel('ORDER SUMMARY'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: _AppColors.cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          ..._selectedItems.asMap().entries.map((entry) {
                            final i = entry.key;
                            final item = entry.value;
                            final isLast = i == _selectedItems.length - 1;
                            return _buildOrderItem(item, isLast);
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Price Breakdown ──────────────────────────
                    _buildSectionLabel('PRICE BREAKDOWN'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _AppColors.cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow('Subtotal', formatRupiah(_subtotal), isTotal: false),
                          const SizedBox(height: 10),
                          _buildPriceRow('Shipping', formatRupiah(_shippingCost), isTotal: false),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(color: _AppColors.textSecondary, height: 1),
                          ),
                          _buildPriceRow('Total', formatRupiah(totalCost), isTotal: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Delivery Address ─────────────────────────
                    _buildSectionLabel('DELIVERY ADDRESS'),
                    const SizedBox(height: 12),
                    _isLoadingAddresses
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            decoration: BoxDecoration(
                              color: _AppColors.cardColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(color: _AppColors.accentColor),
                            ),
                          )
                        : GestureDetector(
                            key: const Key('area_alamat'),
                            onTap: () => _showAddressSelectionBottomSheet(context),
                            child: Container(
                              height: 140,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _AppColors.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _AppColors.accentColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _AppColors.accentColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.location_on_rounded,
                                        color: _AppColors.accentColor, size: 22),
                                  ),
                                  const SizedBox(width: 16),
                                  _currentAddress == null
                                      ? Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: const [
                                                  Text(
                                                    'Belum ada alamat pengiriman',
                                                    style: TextStyle(
                                                      color: _AppColors.textPrimary,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Tambah',
                                                    style: TextStyle(
                                                      color: _AppColors.accentColor,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              const Text(
                                                'Ketuk kartu ini untuk menambahkan alamat baru.',
                                                style: TextStyle(
                                                  color: _AppColors.textSecondary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        _currentAddress!['name']!,
                                                        key: const Key('selected_address_name'),
                                                        style: const TextStyle(
                                                          color: _AppColors.textPrimary,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      if (_currentAddress!['isDefault'] == 'true') ...[
                                                        const SizedBox(width: 8),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: _AppColors.accentColor
                                                                .withValues(alpha: 0.15),
                                                            borderRadius: BorderRadius.circular(6),
                                                            border: Border.all(
                                                                color: _AppColors.accentColor,
                                                                width: 1),
                                                          ),
                                                          child: const Text(
                                                            'Utama',
                                                            style: TextStyle(
                                                              color: _AppColors.accentColor,
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  const Text(
                                                    'Ubah',
                                                    style: TextStyle(
                                                      color: _AppColors.accentColor,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _currentAddress!['phone']!,
                                                style: const TextStyle(
                                                  color: _AppColors.textSecondary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${_currentAddress!['address']!}\n${_currentAddress!['city']!}, ${_currentAddress!['postalCode']!}',
                                                style: const TextStyle(
                                                  color: _AppColors.textSecondary,
                                                  fontSize: 13,
                                                  height: 1.5,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),

                    const SizedBox(height: 24),

                    // ── Payment Method ────────────────────────────
                    _buildSectionLabel('PAYMENT METHOD'),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      value: 'QRIS',
                      label: 'QRIS',
                      subtitle: 'Scan QR bisa dari semua e-wallet',
                      icon: Icons.qr_code_2_rounded,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      value: 'COD',
                      label: 'Cash on Delivery (COD)',
                      subtitle: 'Bayar saat barang sampai',
                      icon: Icons.payments_outlined,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Bottom Order Button ───────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: _AppColors.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          color: _AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        formatRupiah(totalCost),
                        style: const TextStyle(
                          color: _AppColors.accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isOrdering ? null : () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.accentColor,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: _AppColors.textSecondary.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        elevation: 8,
                        shadowColor: _AppColors.accentColor.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: const Text(
                        'PLACE ORDER',
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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _AppColors.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Icon(Icons.fitness_center,
                        color: _AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'Unknown Product',
                      style: const TextStyle(
                        color: _AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'x${item['quantity']}',
                      style: const TextStyle(
                        color: _AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Text(
                _formatItemPrice(item),
                style: const TextStyle(
                  color: _AppColors.accentColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1,
              color: Color(0xFF3A3A3A),
              indent: 16,
              endIndent: 16),
      ],
    );
  }

  String _formatItemPrice(Map<String, dynamic> item) {
    final price = item['price'] as int? ?? 0;
    final qty = item['quantity'] as int? ?? 1;
    final total = price * qty;
    String numStr = total.toString();
    String result = '';
    for (int i = 0; i < numStr.length; i++) {
      if (i > 0 && (numStr.length - i) % 3 == 0) result += '.';
      result += numStr[i];
    }
    return 'Rp $result';
  }

  Widget _buildPriceRow(String label, String value, {required bool isTotal}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? _AppColors.textPrimary : _AppColors.textSecondary,
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? _AppColors.accentColor : _AppColors.textPrimary,
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String label,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _AppColors.accentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? _AppColors.accentColor.withValues(alpha: 0.15)
                    : _AppColors.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? _AppColors.accentColor : _AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? _AppColors.textPrimary : _AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _AppColors.accentColor : _AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: _AppColors.accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp() {
    return const MaterialApp(
      home: _MockCheckoutPage(),
    );
  }

  /// Helper: buka bottom sheet → buka dialog form tambah alamat
  Future<void> openAddAddressDialog(WidgetTester tester) async {
    // Tap area alamat untuk buka bottom sheet
    await tester.tap(find.byKey(const Key('area_alamat')));
    await tester.pumpAndSettle();

    // Tap tombol TAMBAH ALAMAT BARU di bottom sheet
    await tester.tap(find.byKey(const Key('btn_tambah_alamat')));
    await tester.pumpAndSettle();
  }

  group('S.DP-1 - Input Detail Pengiriman', () {
    // -------------------------------------------------------------------------
    // TC.DP-1.001 | Positive | Memasukkan data pengirim yang valid
    // Pre  : User berada di halaman Checkout
    // Steps:
    //   1. Tap area alamat → bottom sheet terbuka
    //   2. Tap "TAMBAH ALAMAT BARU" → dialog form muncul
    //   3. Isi semua field dengan data valid
    //   4. Klik tombol "Simpan"
    // Expected : Dialog tertutup, alamat tampil di area pengiriman
    // -------------------------------------------------------------------------
    testWidgets(
      '[TC.DP-1.001] Positive - Semua field valid → alamat berhasil disimpan',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Verifikasi halaman Checkout tampil
        expect(find.text('CHECKOUT'), findsOneWidget,
            reason: 'TC.DP-1.001: Halaman Checkout harus tampil');

        // Buka form tambah alamat
        await openAddAddressDialog(tester);

        // Verifikasi dialog form muncul
        expect(find.text('Tambah Alamat Baru'), findsOneWidget,
            reason: 'TC.DP-1.001: Dialog form harus tampil');

        // Isi semua field dengan data valid
        await tester.enterText(
            find.byKey(const Key('field_nama')), 'John Doe');
        await tester.enterText(
            find.byKey(const Key('field_telepon')), '081234567890');
        await tester.enterText(
            find.byKey(const Key('field_alamat')),
            'Jl. Sudirman No. 123, Jakarta Selatan');
        await tester.enterText(
            find.byKey(const Key('field_kota')), 'Jakarta');
        await tester.enterText(
            find.byKey(const Key('field_kode_pos')), '12190');
        await tester.pumpAndSettle();

        // Klik tombol Simpan
        await tester.tap(find.byKey(const Key('btn_simpan')));
        await tester.pumpAndSettle();

        // Expected: dialog & bottom sheet tertutup, alamat muncul di halaman
        expect(find.text('Tambah Alamat Baru'), findsNothing,
            reason: 'TC.DP-1.001: Dialog harus tertutup setelah simpan');
        expect(
          find.byKey(const Key('selected_address_name')),
          findsOneWidget,
          reason:
              'TC.DP-1.001: Nama penerima harus tampil di area pengiriman',
        );
        expect(find.text('John Doe'), findsWidgets);

        // Tidak ada pesan error
        expect(find.text('Nama penerima wajib diisi'), findsNothing);
        expect(find.text('Alamat wajib diisi'), findsNothing);
      },
    );

    // -------------------------------------------------------------------------
    // TC.DP-1.002 | Negative | Nama penerima dikosongkan
    // Pre  : User berada di dialog form tambah alamat
    // Steps:
    //   1. Biarkan nama penerima kosong
    //   2. Isi field lain dengan data valid
    //   3. Klik tombol "Simpan"
    // Expected : Muncul pesan error "Nama penerima wajib diisi"
    // -------------------------------------------------------------------------
    testWidgets(
      '[TC.DP-1.002] Negative - Nama penerima kosong → error validasi',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        await openAddAddressDialog(tester);

        // Biarkan nama kosong, isi field lain
        await tester.enterText(
            find.byKey(const Key('field_telepon')), '081234567890');
        await tester.enterText(
            find.byKey(const Key('field_alamat')), 'Jl. Sudirman No. 123');
        await tester.enterText(
            find.byKey(const Key('field_kota')), 'Jakarta');
        await tester.enterText(
            find.byKey(const Key('field_kode_pos')), '12190');
        await tester.pumpAndSettle();

        // Klik Simpan
        await tester.tap(find.byKey(const Key('btn_simpan')));
        await tester.pumpAndSettle();

        // Expected: error validasi nama muncul
        expect(
          find.text('Nama penerima wajib diisi'),
          findsOneWidget,
          reason: 'TC.DP-1.002: Harus muncul error nama penerima wajib diisi',
        );

        // Dialog TIDAK tertutup
        expect(find.text('Tambah Alamat Baru'), findsOneWidget,
            reason: 'TC.DP-1.002: Dialog tidak boleh tertutup jika ada error');
      },
    );

    // -------------------------------------------------------------------------
    // TC.DP-1.003 | Negative | Alamat lengkap dikosongkan
    // Pre  : User berada di dialog form tambah alamat
    // Steps:
    //   1. Isi nama penerima
    //   2. Biarkan alamat kosong
    //   3. Klik tombol "Simpan"
    // Expected : Muncul pesan error "Alamat wajib diisi"
    // -------------------------------------------------------------------------
    testWidgets(
      '[TC.DP-1.003] Negative - Alamat kosong → error validasi',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        await openAddAddressDialog(tester);

        // Isi nama tapi biarkan alamat kosong
        await tester.enterText(
            find.byKey(const Key('field_nama')), 'John Doe');
        await tester.enterText(
            find.byKey(const Key('field_telepon')), '081234567890');
        // field_alamat sengaja dikosongkan
        await tester.enterText(
            find.byKey(const Key('field_kota')), 'Jakarta');
        await tester.enterText(
            find.byKey(const Key('field_kode_pos')), '12190');
        await tester.pumpAndSettle();

        // Klik Simpan
        await tester.tap(find.byKey(const Key('btn_simpan')));
        await tester.pumpAndSettle();

        // Expected: error validasi alamat muncul
        expect(
          find.text('Alamat wajib diisi'),
          findsOneWidget,
          reason: 'TC.DP-1.003: Harus muncul error alamat wajib diisi',
        );

        // Dialog TIDAK tertutup
        expect(find.text('Tambah Alamat Baru'), findsOneWidget,
            reason: 'TC.DP-1.003: Dialog tidak boleh tertutup jika ada error');
      },
    );

    // -------------------------------------------------------------------------
    // TC.DP-1.004 | Negative | Nomor telepon mengandung huruf
    // Pre  : User berada di dialog form tambah alamat
    // Steps:
    //   1. Ketik huruf pada field Nomor Telepon
    // Expected : Karakter non-angka ditolak oleh FilteringTextInputFormatter
    // -------------------------------------------------------------------------
    testWidgets(
      '[TC.DP-1.004] Negative - Nomor telepon mengandung huruf → input ditolak',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        await openAddAddressDialog(tester);

        // Coba masukkan huruf + simbol + angka
        await tester.enterText(
            find.byKey(const Key('field_telepon')), 'abcABC!@#123');
        await tester.pumpAndSettle();

        // Expected: hanya angka yang tersisa ("123")
        final editableText = tester.widget<EditableText>(
          find
              .descendant(
                of: find.byKey(const Key('field_telepon')),
                matching: find.byType(EditableText),
              )
              .first,
        );

        expect(
          RegExp(r'[a-zA-Z!@#]').hasMatch(editableText.controller.text),
          isFalse,
          reason: 'TC.DP-1.004: Field nomor telepon tidak boleh menerima '
              'huruf atau karakter non-angka',
        );
      },
    );
  });
}
