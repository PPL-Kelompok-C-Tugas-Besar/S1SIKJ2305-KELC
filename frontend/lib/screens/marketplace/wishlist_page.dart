import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/palette.dart';
import 'product_detail_page.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();
    final cartProvider = context.watch<CartProvider>();
    final wishlistItems = wishlistProvider.wishlistItems;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'STORE',
              style: TextStyle(
                color: kTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'WISHLIST',
              style: TextStyle(
                color: kTextPrimary,
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
      body: wishlistItems.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: wishlistItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final product = wishlistItems[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(productId: product.id),
                      ),
                    ).then((_) {
                      // Trigger state refresh if needed
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 75,
                            height: 75,
                            color: kBg,
                            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                ? Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: kTextMuted),
                                  )
                                : const Icon(Icons.fitness_center, color: kTextMuted),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: kTextPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: kAccent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    product.averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: kTextPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '(${product.totalReviews} ulasan)',
                                    style: const TextStyle(
                                      color: kTextMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Actions
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
                              onPressed: () {
                                wishlistProvider.removeFromWishlist(product.id);
                              },
                            ),
                            const SizedBox(height: 12),
                            // Quick Add to Cart Button
                            ElevatedButton(
                              onPressed: product.stock > 0
                                  ? () {
                                      cartProvider.addToCart(product);
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
                                foregroundColor: Colors.black,
                                minimumSize: const Size(80, 32),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                product.stock > 0 ? 'BELI' : 'HABIS',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kCard,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(
                Icons.favorite_border,
                color: kTextMuted,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Wishlist kosong',
              style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simpan produk suplemen favorit Anda di sini untuk membelinya nanti.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextMuted, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 0,
              ),
              child: const Text('Jelajahi Produk', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
