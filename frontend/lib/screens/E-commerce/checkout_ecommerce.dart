import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AppColors {
  static const Color bgColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF292929);
  static const Color accentColor = Color(0xFFCCFF00);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);
}

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final int subtotal;
  final int shippingCost;

  const CheckoutPage({
    super.key,
    required this.selectedItems,
    required this.subtotal,
    required this.shippingCost,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool isOrdering = false;
  String _selectedPayment = 'QRIS';

  int _selectedAddressIndex = 0;
  bool _isLoadingAddresses = true;
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

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => _isLoadingAddresses = true);
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/users/addresses'),
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
            _addresses.clear();
            for (var item in list) {
              _addresses.add({
                'id': item['id'].toString(),
                'name': item['name'].toString(),
                'phone': item['phone'].toString(),
                'address': item['address'].toString(),
                'city': item['city'].toString(),
                'postalCode': item['postalCode'].toString(),
                'isDefault': item['isDefault'].toString(),
              });
            }
            if (_selectedAddressIndex >= _addresses.length) {
              _selectedAddressIndex = 0;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    } finally {
      setState(() => _isLoadingAddresses = false);
    }
  }

  Future<bool> _addAddressToApi({
    required String name,
    required String phone,
    required String address,
    required String city,
    required String postalCode,
    required bool isDefault,
  }) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/users/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'address': address,
          'city': city,
          'postalCode': postalCode,
          'isDefault': isDefault,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          await _fetchAddresses();
          setState(() {
            _selectedAddressIndex = 0;
          });
          return true;
        }
      }
      _showErrorSnackbar('Gagal menyimpan alamat baru');
      return false;
    } catch (e) {
      _showErrorSnackbar('Terjadi kesalahan koneksi saat menambah alamat');
      return false;
    }
  }

  Future<bool> _updateAddressInApi({
    required String addressId,
    required String name,
    required String phone,
    required String address,
    required String city,
    required String postalCode,
    required bool isDefault,
  }) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.put(
        Uri.parse('http://localhost:3000/api/users/addresses/$addressId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'address': address,
          'city': city,
          'postalCode': postalCode,
          'isDefault': isDefault,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          await _fetchAddresses();
          return true;
        }
      }
      _showErrorSnackbar('Gagal memperbarui alamat');
      return false;
    } catch (e) {
      _showErrorSnackbar('Terjadi kesalahan koneksi saat memperbarui alamat');
      return false;
    }
  }

  Future<bool> _deleteAddressFromApi(String addressId) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/users/addresses/$addressId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return true;
        }
      }
      _showErrorSnackbar('Gagal menghapus alamat');
      return false;
    } catch (e) {
      _showErrorSnackbar('Terjadi kesalahan koneksi saat menghapus alamat');
      return false;
    }
  }

  int get totalCost => widget.subtotal + widget.shippingCost;

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

  Future<void> _placeOrder() async {
    if (_currentAddress == null) {
      _showErrorSnackbar('Silakan tambahkan alamat pengiriman terlebih dahulu');
      return;
    }

    setState(() => isOrdering = true);

    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse('http://localhost:3000/checkout/order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'items': widget.selectedItems.map((item) => {
            'product_id': item['product_id'],
            'quantity': item['quantity'],
            'price': item['price'],
            'cart_id': item['id'], // item['id'] is cart_id in cart_ecommerce
          }).toList(),
          'payment_method': _selectedPayment,
          'shipping_address': '${_currentAddress!['address']!}, ${_currentAddress!['city']!}, ${_currentAddress!['postalCode']!}',
          'total': totalCost,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201 && data['success'] == true) {
        setState(() => isOrdering = false);
        _showOrderSuccessDialog();
      } else {
        _showErrorSnackbar(data['message'] ?? 'Pesanan gagal diproses');
      }
    } catch (e) {
      if (mounted) _showErrorSnackbar('Terjadi kesalahan koneksi server');
    } finally {
      if (mounted) setState(() => isOrdering = false);
    }
  }

  void _showAddressSelectionBottomSheet(BuildContext context) {
    _isManagingAddresses = false; // Reset to select mode when opening
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgColor,
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
                          color: AppColors.textPrimary,
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
                            color: AppColors.accentColor,
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
                                    color: AppColors.textSecondary, size: 48),
                                SizedBox(height: 12),
                                Text(
                                  'Belum ada alamat pengiriman',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Silakan tambahkan alamat baru di bawah.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
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
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: !_isManagingAddresses && isSelected
                                          ? AppColors.accentColor
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  ? AppColors.accentColor
                                                  : AppColors.textSecondary,
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? Center(
                                                  child: Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: const BoxDecoration(
                                                      color: AppColors.accentColor,
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
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  address['name']!,
                                                  style: const TextStyle(
                                                    color: AppColors.textPrimary,
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
                                                      color: AppColors.accentColor
                                                          .withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(
                                                          color: AppColors.accentColor,
                                                          width: 1),
                                                    ),
                                                    child: const Text(
                                                      'Utama',
                                                      style: TextStyle(
                                                        color: AppColors.accentColor,
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
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${address['address']!}\n${address['city']!}, ${address['postalCode']!}',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                                height: 1.4,
                                              ),
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
                                              color: AppColors.accentColor, size: 20),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          splashRadius: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          onPressed: () async {
                                            final addressId = address['id'];
                                            if (addressId != null) {
                                              final success =
                                                  await _deleteAddressFromApi(addressId);
                                              if (success) {
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
                                              }
                                            }
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
                      onPressed: () {
                        _showAddAddressDialog(context, onAdd: () {
                          setModalState(() {});
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentColor,
                        side: const BorderSide(color: AppColors.accentColor, width: 1.5),
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
              backgroundColor: AppColors.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                isEditing ? 'Edit Alamat' : 'Tambah Alamat Baru',
                style: const TextStyle(
                  color: AppColors.textPrimary,
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
                        controller: nameController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _buildInputDecoration('Nama Penerima'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Nama penerima wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _buildInputDecoration('Nomor Telepon'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Nomor telepon wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressController,
                        maxLines: 3,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _buildInputDecoration('Alamat Lengkap'),
                        validator: (v) => v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: cityController,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: _buildInputDecoration('Kota'),
                              validator: (v) => v == null || v.isEmpty ? 'Kota wajib diisi' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: postalCodeController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: const TextStyle(color: AppColors.textPrimary),
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
                              value: makeDefault,
                              activeColor: AppColors.accentColor,
                              checkColor: Colors.black,
                              onChanged: (v) {
                                setDialogState(() {
                                  makeDefault = v ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Jadikan Alamat Utama',
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
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
                  child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      bool success = false;
                      if (isEditing) {
                        success = await _updateAddressInApi(
                          addressId: existingAddress['id']!,
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          address: addressController.text.trim(),
                          city: cityController.text.trim(),
                          postalCode: postalCodeController.text.trim(),
                          isDefault: makeDefault,
                        );
                      } else {
                        success = await _addAddressToApi(
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          address: addressController.text.trim(),
                          city: cityController.text.trim(),
                          postalCode: postalCodeController.text.trim(),
                          isDefault: makeDefault,
                        );
                      }
                      if (success && ctx.mounted) {
                        onAdd();
                        Navigator.pop(ctx);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
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

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      filled: true,
      fillColor: AppColors.bgColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentColor, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: Stack(
          children: [
            // Close Button (X)
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                splashRadius: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        color: AppColors.accentColor, size: 56),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Order Placed!',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pesanan kamu berhasil dibuat.\nTerima kasih sudah belanja di Gymbro!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'SHOP',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'CHECKOUT',
              style: TextStyle(
                color: AppColors.textPrimary,
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
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          ...widget.selectedItems.asMap().entries.map((entry) {
                            final i = entry.key;
                            final item = entry.value;
                            final isLast = i == widget.selectedItems.length - 1;
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
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow('Subtotal', formatRupiah(widget.subtotal), isTotal: false),
                          const SizedBox(height: 10),
                          _buildPriceRow('Shipping', formatRupiah(widget.shippingCost), isTotal: false),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(color: AppColors.textSecondary, height: 1),
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
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(color: AppColors.accentColor),
                            ),
                          )
                        : GestureDetector(
                            onTap: () => _showAddressSelectionBottomSheet(context),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.accentColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.location_on_rounded,
                                        color: AppColors.accentColor, size: 22),
                                  ),
                                  const SizedBox(width: 16),
                                  _currentAddress == null
                                      ? Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: const [
                                                  Text(
                                                    'Belum ada alamat pengiriman',
                                                    style: TextStyle(
                                                      color: AppColors.textPrimary,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Tambah',
                                                    style: TextStyle(
                                                      color: AppColors.accentColor,
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
                                                  color: AppColors.textSecondary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        _currentAddress!['name']!,
                                                        style: const TextStyle(
                                                          color: AppColors.textPrimary,
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
                                                            color: AppColors.accentColor
                                                                .withValues(alpha: 0.15),
                                                            borderRadius: BorderRadius.circular(6),
                                                            border: Border.all(
                                                                color: AppColors.accentColor,
                                                                width: 1),
                                                          ),
                                                          child: const Text(
                                                            'Utama',
                                                            style: TextStyle(
                                                              color: AppColors.accentColor,
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
                                                      color: AppColors.accentColor,
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
                                                  color: AppColors.textSecondary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${_currentAddress!['address']!}\n${_currentAddress!['city']!}, ${_currentAddress!['postalCode']!}',
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 13,
                                                  height: 1.5,
                                                ),
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
                color: AppColors.cardColor,
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
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        formatRupiah(totalCost),
                        style: const TextStyle(
                          color: AppColors.accentColor,
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
                      onPressed: isOrdering ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        elevation: 8,
                        shadowColor: AppColors.accentColor.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: isOrdering
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2.5),
                            )
                          : const Text(
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
        color: AppColors.textSecondary,
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
                  color: AppColors.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item['image'] != null &&
                          item['image'].toString().startsWith('http')
                      ? Image.network(
                          item['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(Icons.fitness_center,
                                color: AppColors.textSecondary),
                          ),
                        )
                      : Image.asset(
                          item['image'] ?? 'assets/whey.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(Icons.fitness_center,
                                color: AppColors.textSecondary),
                          ),
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
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item['variant'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item['variant'],
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      'x${item['quantity']}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
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
                  color: AppColors.accentColor,
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
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? AppColors.accentColor : AppColors.textPrimary,
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
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentColor.withValues(alpha: 0.15)
                    : AppColors.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.accentColor : AppColors.textSecondary,
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
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.accentColor : AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.accentColor,
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
