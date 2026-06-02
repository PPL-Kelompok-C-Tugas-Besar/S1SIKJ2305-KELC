import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';
import '../models/voucher_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(json['product']),
        quantity: json['quantity'] as int,
      );
}

class CartProvider with ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _cartKey = 'gymbro_shopping_cart';

  Map<int, CartItem> _items = {};
  Voucher? _appliedVoucher;

  CartProvider() {
    _loadCart();
  }

  Voucher? get appliedVoucher => _appliedVoucher;

  double get discountAmount {
    if (_appliedVoucher == null) return 0.0;
    
    // Safety check for minimum purchase
    if (totalPrice < _appliedVoucher!.minimumPurchase) {
      return 0.0;
    }

    if (_appliedVoucher!.discountType == 'percentage') {
      double discount = totalPrice * (_appliedVoucher!.discountValue / 100);
      if (_appliedVoucher!.maxDiscount > 0 && discount > _appliedVoucher!.maxDiscount) {
        discount = _appliedVoucher!.maxDiscount;
      }
      return discount;
    } else {
      return _appliedVoucher!.discountValue;
    }
  }

  double get finalPrice {
    double finalVal = totalPrice - discountAmount;
    return finalVal < 0 ? 0.0 : finalVal;
  }

  void applyVoucher(Voucher? voucher) {
    _appliedVoucher = voucher;
    notifyListeners();
  }

  void _validateVoucher() {
    if (_appliedVoucher != null) {
      if (totalPrice < _appliedVoucher!.minimumPurchase) {
        _appliedVoucher = null;
      }
    }
  }

  Map<int, CartItem> get items => _items;

  List<CartItem> get cartItems => _items.values.toList();

  int get totalItems {
    int total = 0;
    _items.forEach((key, item) {
      total += item.quantity;
    });
    return total;
  }

  double get totalPrice {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.product.price * item.quantity;
    });
    return total;
  }

  Future<void> _loadCart() async {
    try {
      final cartStr = await _storage.read(key: _cartKey);
      if (cartStr != null) {
        final List<dynamic> decoded = json.decode(cartStr);
        _items = {
          for (var item in decoded)
            (item['product']['id'] is int 
                ? item['product']['id'] as int 
                : int.parse(item['product']['id'].toString())): CartItem.fromJson(item)
        };
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final list = _items.values.map((item) => item.toJson()).toList();
      await _storage.write(key: _cartKey, value: json.encode(list));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<void> addToCart(Product product) async {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    _validateVoucher();
    notifyListeners();
    await _saveCart();
  }

  Future<void> incrementQuantity(int productId) async {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity += 1;
      _validateVoucher();
      notifyListeners();
      await _saveCart();
    }
  }

  Future<void> decrementQuantity(int productId) async {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId]!.quantity -= 1;
      } else {
        _items.remove(productId);
      }
      _validateVoucher();
      notifyListeners();
      await _saveCart();
    }
  }

  Future<void> removeFromCart(int productId) async {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      _validateVoucher();
      notifyListeners();
      await _saveCart();
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    _appliedVoucher = null;
    notifyListeners();
    await _saveCart();
  }
}
