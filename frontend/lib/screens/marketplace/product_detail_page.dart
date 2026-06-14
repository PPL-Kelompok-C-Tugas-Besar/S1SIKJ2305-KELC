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
import '../../logic/quantity_logic.dart';
import 'cart_page.dart';

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
  late QuantityLogic _qLogic;

  @override
  void initState() {
    super.initState();
    _qLogic = QuantityLogic(stock: 0);
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
        final prod = result['data'] as Product;
        setState(() {
          _product = prod;
          _qLogic = QuantityLogic(stock: prod.stock);
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextPrimary),
        title: const Text(
          'SHOP',
          style: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
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
                  'Maaf! Stok ${_product?.name} hanya tersisa ${_product?.stock}.',
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
                // Product Image with soft glowing shadow
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: kAccent.withValues(alpha: 0.05),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                ),
                
                // Content Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
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
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            product.stock > 0 ? 'Stok: ${product.stock}' : 'Stok Habis',
                            style: TextStyle(color: stockColor, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Price & Weight Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rp ${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: kAccent,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (product.weightGrams != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: kCard,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: kTextMuted.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.scale_outlined, size: 14, color: kTextMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    product.weightGrams! >= 1000
                                        ? '${(product.weightGrams! / 1000).toStringAsFixed(product.weightGrams! % 1000 == 0 ? 0 : 1)} kg'
                                        : '${product.weightGrams} g',
                                    style: const TextStyle(
                                      color: kTextMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
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

        // Pinned CTA & Quantity Section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(
            color: kCard,
            border: Border(top: BorderSide(color: Colors.white10)),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quantity Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Minus Button
                    Container(
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kTextMuted.withValues(alpha: 0.3)),
                      ),
                      child: IconButton(
                        onPressed: _decrement,
                        icon: const Icon(Icons.remove, color: kTextPrimary),
                        tooltip: 'Decrease quantity',
                      ),
                    ),
                    
                    // Quantity Value
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        '${_qLogic.quantity}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                    
                    // Plus Button
                    Container(
                      decoration: BoxDecoration(
                        color: kAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: _increment,
                        icon: const Icon(Icons.add, color: kBg),
                        tooltip: 'Increase quantity',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: product.stock > 0
                            ? () {
                                cart.addToCart(product, quantity: _qLogic.quantity);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} dimasukkan ke keranjang'),
                                    backgroundColor: kCard,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          side: const BorderSide(color: kAccent, width: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text(
                          'ADD TO CART',
                          style: TextStyle(
                            color: kAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: product.stock > 0
                            ? () {
                                cart.addToCart(product, quantity: _qLogic.quantity);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CartPage()),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          elevation: 8,
                          shadowColor: kAccent.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text(
                          'PURCHASE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
