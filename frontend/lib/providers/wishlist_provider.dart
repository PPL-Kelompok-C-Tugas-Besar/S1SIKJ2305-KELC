import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';

class WishlistProvider with ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _wishlistKey = 'gymbro_wishlist';

  Map<int, Product> _items = {};

  WishlistProvider() {
    _loadWishlist();
  }

  List<Product> get wishlistItems => _items.values.toList();

  bool isWishlisted(int productId) {
    return _items.containsKey(productId);
  }

  Future<void> _loadWishlist() async {
    try {
      final wishlistStr = await _storage.read(key: _wishlistKey);
      if (wishlistStr != null) {
        final List<dynamic> decoded = json.decode(wishlistStr);
        _items = {
          for (var item in decoded)
            (item['id'] is int 
                ? item['id'] as int 
                : int.parse(item['id'].toString())): Product.fromJson(item)
        };
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  Future<void> _saveWishlist() async {
    try {
      final list = _items.values.map((item) => item.toJson()).toList();
      await _storage.write(key: _wishlistKey, value: json.encode(list));
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }

  Future<void> toggleWishlist(Product product) async {
    if (_items.containsKey(product.id)) {
      _items.remove(product.id);
    } else {
      _items[product.id] = product;
    }
    notifyListeners();
    await _saveWishlist();
  }

  Future<void> removeFromWishlist(int productId) async {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      notifyListeners();
      await _saveWishlist();
    }
  }
}
