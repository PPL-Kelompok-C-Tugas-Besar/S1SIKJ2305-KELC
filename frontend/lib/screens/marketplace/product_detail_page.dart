import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart';
import '../../services/supplement_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/palette.dart';
import 'write_review_page.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final SupplementService _supplementService = SupplementService();
  Product? _product;
  List<Review> _reviews = [];
  bool _isLoadingProduct = true;
  bool _isLoadingReviews = true;
  String? _productError;
  String? _reviewsError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadProduct();
    _loadReviews();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoadingProduct = true;
      _productError = null;
    });
    final result = await _supplementService.getProductById(widget.productId);
    if (mounted) {
      if (result['success']) {
        setState(() {
          _product = result['data'];
          _isLoadingProduct = false;
        });
      } else {
        setState(() {
          _productError = result['message'];
          _isLoadingProduct = false;
        });
      }
    }
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });
    final result = await _supplementService.getProductReviews(widget.productId);
    if (mounted) {
      if (result['success']) {
        setState(() {
          _reviews = result['data'];
          _isLoadingReviews = false;
        });
      } else {
        setState(() {
          _reviewsError = result['message'];
          _isLoadingReviews = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();
    final cartProvider = context.watch<CartProvider>();

    final isWish = _product != null && wishlistProvider.isWishlisted(_product!.id);

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Produk', style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
        actions: [
          if (_product != null)
            IconButton(
              icon: Icon(
                isWish ? Icons.favorite : Icons.favorite_border,
                color: isWish ? Colors.red : kTextPrimary,
              ),
              onPressed: () => wishlistProvider.toggleWishlist(_product!),
            ),
        ],
      ),
      body: _isLoadingProduct
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : _productError != null
              ? _buildErrorState()
              : _buildProductDetails(cartProvider),
    );
  }

  Widget _buildProductDetails(CartProvider cart) {
    final product = _product!;
    final stockColor = product.stock > 5
        ? Colors.green
        : product.stock > 0
            ? Colors.orange
            : Colors.red;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: double.infinity,
                  height: 280,
                  color: Colors.white10,
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
                
                // Content Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      if (product.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.category!.toUpperCase(),
                            style: const TextStyle(color: kAccent, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price & Stock
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rp ${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: kAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            product.stock > 0 ? 'Stok: ${product.stock}' : 'Stok Habis',
                            style: TextStyle(color: stockColor, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 30),

                      // Description
                      const Text(
                        'Deskripsi Produk',
                        style: TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description ?? 'Tidak ada deskripsi untuk produk ini.',
                        style: const TextStyle(color: kTextMuted, fontSize: 14, height: 1.5),
                      ),
                      const Divider(color: Colors.white10, height: 30),

                      // Rating & Reviews Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ulasan & Rating',
                            style: TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WriteReviewPage(productId: product.id),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  _loadData();
                                }
                              });
                            },
                            icon: const Icon(Icons.rate_review, color: kAccent, size: 16),
                            label: const Text(
                              'Tulis Ulasan',
                              style: TextStyle(color: kAccent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Average Rating Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  product.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: kTextPrimary,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < product.averageRating.round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${product.totalReviews} Ulasan',
                                  style: const TextStyle(color: kTextMuted, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            // Vertical Divider
                            Container(
                              height: 60,
                              width: 1,
                              color: Colors.white10,
                            ),
                            const SizedBox(width: 24),
                            const Expanded(
                              child: Text(
                                'Rating diberikan oleh pembeli terverifikasi Gymbro.',
                                style: TextStyle(color: kTextMuted, fontSize: 12, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reviews List
                      _isLoadingReviews
                          ? const Center(child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(color: kAccent),
                            ))
                          : _reviewsError != null
                              ? Text(_reviewsError!, style: const TextStyle(color: Colors.red))
                              : _reviews.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 24),
                                      child: Center(
                                        child: Text(
                                          'Belum ada ulasan untuk produk ini.',
                                          style: TextStyle(color: kTextMuted, fontSize: 13),
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _reviews.length,
                                      separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 24),
                                      itemBuilder: (context, index) {
                                        final rev = _reviews[index];
                                        final dateFormatted = DateFormat('dd MMM yyyy').format(rev.createdAt);

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  rev.userName,
                                                  style: const TextStyle(
                                                    color: kTextPrimary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  dateFormatted,
                                                  style: const TextStyle(color: kTextMuted, fontSize: 11),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: List.generate(5, (starIdx) {
                                                return Icon(
                                                  starIdx < rev.rating
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 14,
                                                );
                                              }),
                                            ),
                                            if (rev.reviewText != null && rev.reviewText!.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                rev.reviewText!,
                                                style: const TextStyle(color: kTextMuted, fontSize: 13, height: 1.4),
                                              ),
                                            ]
                                          ],
                                        );
                                      },
                                    ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // CTA Section (Add to Cart / Out of Stock)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: kCard,
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: product.stock > 0
                    ? () {
                        cart.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} dimasukkan ke keranjang'),
                            backgroundColor: kCard,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: kBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  product.stock > 0 ? 'Beli Sekarang' : 'Stok Habis',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Icon(Icons.image, color: kTextMuted, size: 60),
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
              _productError ?? 'Terjadi kesalahan saat memuat data',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextPrimary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: kBg),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
