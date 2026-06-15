import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../logic/quantity_logic.dart';
import '../../services/auth_service.dart';
import 'checkout_ecommerce.dart';

class AppColors {
  static const Color bgColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF292929);
  static const Color accentColor = Color(0xFFCCFF00);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);
}

class ProductDetailPage extends StatefulWidget {
  final String productName;
  final int productId;
  final String imagePath;
  final String price;
  final int stock;
  final int? weightGrams;
  
  const ProductDetailPage({
    super.key, 
    required this.productName, 
    required this.productId,
    required this.imagePath, 
    required this.price,
    required this.stock,
    this.weightGrams,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late QuantityLogic _qLogic;

  // Reviews state
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = false;
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _qLogic = QuantityLogic(stock: widget.stock);
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('http://localhost:3000/products/${widget.productId}/reviews'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final list = List<Map<String, dynamic>>.from(data['data'] ?? []);
          double avg = 0;
          if (list.isNotEmpty) {
            avg = list.fold<double>(0, (sum, r) => sum + (num.tryParse(r['rating'].toString()) ?? 0)) / list.length;
          }
          if (mounted) {
            setState(() {
              _reviews = list;
              _averageRating = avg;
            });
          }
        }
      }
    } catch (e) {
      // silently fail
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  void _increment() {
    final success = _qLogic.increment();
    if (success) {
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Maaf! Stok ${widget.productName} hanya tersisa ${widget.stock}.',
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
  }

  void _decrement() {
    final success = _qLogic.decrement();
    if (success) {
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Minimal pembelian 1 item',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  int _parsedPrice() {
    final cleaned = widget.price
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();
    return int.tryParse(cleaned) ?? 0;
  }

  void _goToCheckout() {
    final price = _parsedPrice();
    final qty = _qLogic.quantity;
    const int shippingCost = 50000;

    final item = {
      'product_id': widget.productId,
      'name': widget.productName,
      'image': widget.imagePath,
      'price': price,
      'quantity': qty,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          selectedItems: [item],
          subtotal: price * qty,
          shippingCost: shippingCost,
        ),
      ),
    );
  }

  void _showWriteReviewDialog() {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'TULIS ULASAN',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Star rating selector
                  Row(
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedRating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            i < selectedRating ? Icons.star : Icons.star_border,
                            color: AppColors.accentColor,
                            size: 36,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Bagikan pengalaman Anda dengan produk ini...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.bgColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.accentColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _submitReview(selectedRating, commentController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'KIRIM ULASAN',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _submitReview(int rating, String comment) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan login terlebih dahulu')));
        return;
      }
      final response = await http.post(
        Uri.parse('http://localhost:3000/products/${widget.productId}/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'rating': rating, 'review_text': comment}),
      );
      if (mounted) {
        if (response.statusCode == 201 || response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ulasan berhasil dikirim!'), backgroundColor: Colors.green),
          );
          _loadReviews();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengirim ulasan'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Koneksi gagal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'SHOP',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Image with soft glowing shadow
                    SizedBox(
                      height: 260,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentColor.withValues(alpha: 0.05),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: widget.imagePath.startsWith('http')
                              ? Image.network(
                                  widget.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.fitness_center, color: AppColors.textSecondary, size: 60),
                                  ),
                                )
                              : Image.asset(
                                  widget.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.fitness_center, color: AppColors.textSecondary, size: 60),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    
                    // Product Name, Price & Weight
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          widget.price,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            color: AppColors.accentColor,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        if (widget.weightGrams != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.scale_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  widget.weightGrams! >= 1000 ? '${(widget.weightGrams! / 1000).toStringAsFixed(widget.weightGrams! % 1000 == 0 ? 0 : 1)} kg' : '${widget.weightGrams} g',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Quantity Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                          ),
                          child: IconButton(
                            onPressed: _decrement,
                            icon: const Icon(Icons.remove, color: AppColors.textPrimary),
                            tooltip: 'Decrease quantity',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            '${_qLogic.quantity}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: _increment,
                            icon: const Icon(Icons.add, color: AppColors.bgColor),
                            tooltip: 'Increase quantity',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    
                    // CTA Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context, _qLogic.quantity);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18.0),
                              side: const BorderSide(color: AppColors.accentColor, width: 2.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: const Text(
                              'ADD TO CART',
                              style: TextStyle(
                                color: AppColors.accentColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _goToCheckout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 18.0),
                              elevation: 8,
                              shadowColor: AppColors.accentColor.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: const Text(
                              'PURCHASE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── Rating & Review Section ──────────────────────────────
                    const SizedBox(height: 32),
                    _buildReviewSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RATING & ULASAN',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (_reviews.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.accentColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${_averageRating.toStringAsFixed(1)} (${_reviews.length} ulasan)',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            TextButton.icon(
              onPressed: _showWriteReviewDialog,
              icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.accentColor),
              label: const Text(
                'TULIS ULASAN',
                style: TextStyle(
                  color: AppColors.accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Review list
        if (_isLoadingReviews)
          const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(color: AppColors.accentColor),
          ))
        else if (_reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.rate_review_outlined, color: AppColors.textSecondary, size: 40),
                SizedBox(height: 8),
                Text(
                  'Belum ada ulasan untuk produk ini.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...List.generate(_reviews.length > 3 ? 3 : _reviews.length, (index) {
            final review = _reviews[index];
            final rating = int.tryParse(review['rating'].toString()) ?? 0;
            final comment = review['comment']?.toString() ?? '';
            final userName = review['user_name']?.toString() ?? 'Pengguna';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: AppColors.accentColor,
                          size: 14,
                        )),
                      ),
                    ],
                  ),
                  if (comment.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      comment,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

        if (_reviews.length > 3) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppColors.bgColor,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.7,
                    maxChildSize: 0.9,
                    minChildSize: 0.4,
                    expand: false,
                    builder: (context, scrollController) => ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: _reviews.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)))),
                              const SizedBox(height: 16),
                              const Text('SEMUA ULASAN', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
                            ],
                          );
                        }
                        final review = _reviews[index - 1];
                        final rating = int.tryParse(review['rating'].toString()) ?? 0;
                        final comment = review['comment']?.toString() ?? '';
                        final userName = review['user_name']?.toString() ?? 'Pengguna';
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(userName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                                  Row(children: List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: AppColors.accentColor, size: 14))),
                                ],
                              ),
                              if (comment.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(comment, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              child: const Text(
                'Lihat semua ulasan',
                style: TextStyle(color: AppColors.accentColor, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}