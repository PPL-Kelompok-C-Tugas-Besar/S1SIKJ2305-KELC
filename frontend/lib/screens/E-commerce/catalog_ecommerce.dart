import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'detailcatalog_ecommerce.dart';
import 'cart_ecommerce.dart';
import 'purchase_history.dart';
import '../../services/auth_service.dart';

class AppColors {
  static const Color bgColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF292929);
  static const Color accentColor = Color(0xFFCCFF00);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);
}

class ShopPage extends StatefulWidget {
  final List<dynamic>? manualProducts; // Untuk testing
  const ShopPage({super.key, this.manualProducts});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<dynamic> products = [];
  bool isLoading = true;
  String errorMessage = '';
  int cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.manualProducts != null) {
      products = widget.manualProducts!;
      isLoading = false;
    } else {
      fetchProducts();
      fetchCartCount();
    }
  }

  Future<void> fetchCartCount() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return;
      
      final response = await http.get(
        Uri.parse('http://localhost:3000/cart'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          int count = 0;
          for (var item in data['data']) {
            count += (item['quantity'] as num).toInt();
          }
          if (mounted) {
            setState(() {
              cartItemCount = count;
            });
          }
        }
      }
    } catch (e) {
      // ignore error
    }
  }

  // Fungsi buat ngerubah angka jadi format Rupiah (contoh: 850000 -> Rp 850.000)
  String formatRupiah(int? number) {
    if (number == null) return 'Rp 0';
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

  Future<void> fetchProducts() async {
    try {
      // Narik data dari backend Node.js lu
      final response = await http.get(Uri.parse('http://localhost:3000/products'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            products = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Gagal mengambil data produk';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Tidak bisa connect ke server -_-.';
        isLoading = false;
      });
    }
  }

  Future<void> _addToCart(int productId, int quantity) async {
    try {
      final token = await AuthService().getToken();
      if (token == null && widget.manualProducts == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan login terlebih dahulu')));
        return;
      }

      // Skip API if manual mode
      if (widget.manualProducts != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menambahkan ke cart (Mock Mode)')));
        return;
      }
      
      final response = await http.post(
        Uri.parse('http://localhost:3000/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;
      if (response.statusCode == 201 && data['success'] == true) {
        setState(() {
          cartItemCount += quantity;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil ditambahkan ke cart'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Gagal menambahkan ke cart'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak bisa terhubung ke server'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartPage()),
          ).then((_) {
            fetchCartCount();
          });
        },
        backgroundColor: Colors.white,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 28),
            if (cartItemCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header Row
              Row(
                children: [
                  const Text(
                    'SHOP',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search supplements...',
                          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.accentColor),
                          filled: true,
                          fillColor: AppColors.cardColor,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: AppColors.accentColor, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.receipt_long_outlined, color: AppColors.textPrimary),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PurchaseHistoryPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.sort, color: AppColors.textPrimary),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Grid View atau Loading State
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.accentColor),
                      )
                    : errorMessage.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.sentiment_dissatisfied, size: 80, color: AppColors.textSecondary),
                                const SizedBox(height: 16),
                                Text(
                                  errorMessage,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final int productId = product['id'] ?? 0;
                              final String productName = product['name'] ?? 'Unknown';
                              final String imagePath = product['image_url'] ?? 'assets/whey.png';
                              final String priceFormatted = formatRupiah(product['price']);
                              final int stock = product['stock'] ?? 0;
                              final int? weightGrams = product['weight_grams'];

                              return GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(
                                        productName: productName,
                                        productId: productId,
                                        imagePath: imagePath,
                                        price: priceFormatted,
                                        stock: stock,
                                        weightGrams: weightGrams,
                                      ),
                                    ),
                                  );
                                  if (result != null && result is int) {
                                    await _addToCart(productId, result);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.cardColor,
                                    borderRadius: BorderRadius.circular(16.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                                          child: Container(
                                            color: AppColors.cardColor,
                                            child: imagePath.startsWith('http')
                                                ? Image.network(
                                                    imagePath,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => const Center(
                                                      child: Icon(Icons.fitness_center, color: AppColors.textSecondary, size: 40),
                                                    ),
                                                  )
                                                : Image.asset(
                                                    imagePath,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => const Center(
                                                      child: Icon(Icons.fitness_center, color: AppColors.textSecondary, size: 40),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              productName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              priceFormatted,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                                color: AppColors.accentColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
