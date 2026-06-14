import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../services/supplement_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/palette.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';
import 'wishlist_page.dart';
import 'purchase_history_page.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final SupplementService _supplementService = SupplementService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;

  // Filter & Sort States (Client side to match E-commerce features)
  String _searchQuery = '';
  double? _minPrice;
  double? _maxPrice;
  String _selectedCategory = 'Semua';
  List<String> _categories = ['Semua'];
  String _sortBy = 'id_desc'; // Options: id_desc (Latest), price_asc, price_desc, name_asc, name_desc

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _supplementService.getMarketplaceProducts();
    if (result['success']) {
      final List<Product> loaded = result['data'];
      setState(() {
        _products = loaded;
        
        // Extract unique categories
        final cats = {'Semua'};
        for (var p in loaded) {
          if (p.category != null && p.category!.isNotEmpty) {
            cats.add(p.category!);
          }
        }
        _categories = cats.toList();
        _applyFilters();
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['message'];
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      // 1. Filter by search, category, and price range
      var temp = _products.where((p) {
        final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (p.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        final matchesCategory = _selectedCategory == 'Semua' || p.category == _selectedCategory;
        final matchesMinPrice = _minPrice != null ? p.price >= _minPrice! : true;
        final matchesMaxPrice = _maxPrice != null ? p.price <= _maxPrice! : true;
        return matchesSearch && matchesCategory && matchesMinPrice && matchesMaxPrice;
      }).toList();

      // 2. Sort results
      if (_sortBy == 'price_asc') {
        temp.sort((a, b) => a.price.compareTo(b.price));
      } else if (_sortBy == 'price_desc') {
        temp.sort((a, b) => b.price.compareTo(a.price));
      } else if (_sortBy == 'name_asc') {
        temp.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else if (_sortBy == 'name_desc') {
        temp.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      } else {
        // Default (Latest / ID Desc)
        temp.sort((a, b) => b.id.compareTo(a.id));
      }

      _filteredProducts = temp;
    });
  }

  void _showFilterBottomSheet() {
    double tempMin = _minPrice ?? 0;
    double tempMax = _maxPrice ?? 10000000;
    String tempCategory = _selectedCategory;

    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20, 
                right: 20, 
                top: 20, 
                bottom: MediaQuery.of(context).viewInsets.bottom + 20
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Range',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: kTextPrimary),
                          decoration: InputDecoration(
                            labelText: 'Min Price',
                            labelStyle: const TextStyle(color: kTextMuted),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: kTextMuted),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: kAccent),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            tempMin = double.tryParse(value) ?? 0;
                          },
                          controller: TextEditingController(text: tempMin > 0 ? tempMin.toInt().toString() : ''),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: kTextPrimary),
                          decoration: InputDecoration(
                            labelText: 'Max Price',
                            labelStyle: const TextStyle(color: kTextMuted),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: kTextMuted),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: kAccent),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            tempMax = double.tryParse(value) ?? 10000000;
                          },
                          controller: TextEditingController(text: tempMax < 10000000 ? tempMax.toInt().toString() : ''),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Category',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSel = tempCategory == cat;
                      return ChoiceChip(
                        label: Text(
                          cat.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: isSel ? Colors.black : kTextPrimary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: kAccent,
                        backgroundColor: kBg,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSel ? kAccent : Colors.white10,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              tempCategory = cat;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _minPrice = null;
                              _maxPrice = null;
                              _selectedCategory = 'Semua';
                            });
                            Navigator.pop(context);
                            _applyFilters();
                          },
                          child: const Text('Reset', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _minPrice = tempMin;
                              _maxPrice = tempMax;
                              _selectedCategory = tempCategory;
                            });
                            Navigator.pop(context);
                            _applyFilters();
                          },
                          child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Sort By',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildSortOption('Latest', 'id_desc'),
            _buildSortOption('Price: Low to High', 'price_asc'),
            _buildSortOption('Price: High to Low', 'price_desc'),
            _buildSortOption('Name: A to Z', 'name_asc'),
            _buildSortOption('Name: Z to A', 'name_desc'),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildSortOption(String label, String value) {
    bool isSelected = _sortBy == value;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? kAccent : kTextPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: kAccent) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
        _applyFilters();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartPage()),
          ).then((_) {
            _loadProducts();
          });
        },
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 28),
            if (cartProvider.totalItems > 0)
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
              // Header Row (Exact match to E-commerce catalog style)
              Row(
                children: [
                  const Text(
                    'SHOP',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: kTextPrimary),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _applyFilters();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search supplements...',
                          hintStyle: const TextStyle(color: kTextMuted, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, size: 20, color: kAccent),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20, color: kTextMuted),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                    _applyFilters();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: kCard,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: kAccent, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Riwayat / Receipt Button
                  Container(
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.receipt_long_outlined, color: kTextPrimary),
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
                  // Filter Button
                  Container(
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, color: kTextPrimary),
                      onPressed: _showFilterBottomSheet,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sort Button
                  Container(
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.sort, color: kTextPrimary),
                      onPressed: _showSortBottomSheet,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Wishlist Button (Added next to Sort to keep layout clean and support Wishlist feature)
                  Container(
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: kTextPrimary),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WishlistPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Grid View or States
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadProducts,
                  color: kAccent,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: kAccent))
                      : _error != null
                          ? _buildErrorState()
                          : _filteredProducts.isEmpty
                              ? _buildEmptyState()
                              : _buildProductsGrid(wishlistProvider, cartProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid(WishlistProvider wishlist, CartProvider cart) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.72,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        final isWish = wishlist.isWishlisted(product.id);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(productId: product.id),
              ),
            ).then((_) => _loadProducts()); // Reload rating / counts
          },
          child: Container(
            decoration: BoxDecoration(
              color: kCard,
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
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                          child: Container(
                            color: kCard,
                            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                ? Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                  )
                                : _buildPlaceholder(),
                          ),
                        ),
                      ),
                      // Wishlist Toggle Overlay
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => wishlist.toggleWishlist(product),
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withValues(alpha: 0.5),
                            radius: 18,
                            child: Icon(
                              isWish ? Icons.favorite : Icons.favorite_border,
                              color: isWish ? Colors.red : kTextPrimary,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: kTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: kAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Rating & Review details
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 13),
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
                            '(${product.totalReviews})',
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Icons.fitness_center, color: kTextMuted, size: 40),
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
              _error ?? 'Terjadi kesalahan saat memuat data',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextPrimary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('COBA LAGI', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.storefront_outlined, color: kTextMuted, size: 60),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada produk yang ditemukan',
            style: TextStyle(color: kTextMuted, fontSize: 16),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'Semua' || _minPrice != null || _maxPrice != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedCategory = 'Semua';
                  _minPrice = null;
                  _maxPrice = null;
                  _applyFilters();
                });
              },
              child: const Text('Reset Filter', style: TextStyle(color: kAccent)),
            ),
        ],
      ),
    );
  }
}
