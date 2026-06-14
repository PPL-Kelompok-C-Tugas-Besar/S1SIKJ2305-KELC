import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/supplement_service.dart';

class WishlistProvider with ChangeNotifier {
  final _supplementService = SupplementService();
  Map<int, Product> _items = {};
  bool _isLoading = false;

  WishlistProvider() {
    loadWishlist();
  }

  List<Product> get wishlistItems => _items.values.toList();
  bool get isLoading => _isLoading;

  bool isWishlisted(int productId) {
    return _items.containsKey(productId);
  }

  Future<void> loadWishlist() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _supplementService.getWishlist();
      if (result['success'] == true) {
        final List<Product> products = result['data'];
        _items = {for (var p in products) p.id: p};
      }
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(Product product) async {
    final int productId = product.id;
    if (_items.containsKey(productId)) {
      // Optimistic UI update
      _items.remove(productId);
      notifyListeners();
      try {
        await _supplementService.removeFromWishlist(productId);
      } catch (e) {
        debugPrint('Error removing from wishlist: $e');
        // Rollback
        _items[productId] = product;
        notifyListeners();
      }
    } else {
      // Optimistic UI update
      _items[productId] = product;
      notifyListeners();
      try {
        await _supplementService.addToWishlist(productId);
      } catch (e) {
        debugPrint('Error adding to wishlist: $e');
        // Rollback
        _items.remove(productId);
        notifyListeners();
      }
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    if (_items.containsKey(productId)) {
      final product = _items[productId];
      _items.remove(productId);
      notifyListeners();
      try {
        await _supplementService.removeFromWishlist(productId);
      } catch (e) {
        debugPrint('Error removing from wishlist: $e');
        // Rollback
        if (product != null) {
          _items[productId] = product;
          notifyListeners();
        }
      }
    }
  }
}
