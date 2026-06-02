import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../models/voucher_model.dart';
import '../models/order_model.dart';
import 'api_constants.dart';

class SupplementService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  Future<String?> _getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // GET /api/marketplace/products
  Future<Map<String, dynamic>> getMarketplaceProducts() async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak ditemukan. Silakan login.'};

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/marketplace/products'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> raw = data['data'] ?? [];
        final products = raw.map((e) => Product.fromJson(e)).toList();
        return {'success': true, 'data': products};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil data produk'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }

  // GET /api/marketplace/products/:id
  Future<Map<String, dynamic>> getProductById(int id) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak ditemukan. Silakan login.'};

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/marketplace/products/$id'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        final product = Product.fromJson(data['data']);
        return {'success': true, 'data': product};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil detail produk'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }

  // GET /api/marketplace/products/:id/reviews
  Future<Map<String, dynamic>> getProductReviews(int productId) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak ditemukan. Silakan login.'};

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/marketplace/products/$productId/reviews'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> raw = data['data'] ?? [];
        final reviews = raw.map((e) => Review.fromJson(e)).toList();
        return {'success': true, 'data': reviews};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil ulasan produk'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }

  // POST /api/marketplace/products/:id/reviews
  Future<Map<String, dynamic>> submitReview(int productId, int rating, String? reviewText) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak ditemukan. Silakan login.'};

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/marketplace/products/$productId/reviews'),
        headers: _authHeaders(token),
        body: json.encode({
          'rating': rating,
          'review_text': reviewText,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Ulasan berhasil dikirim'};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengirim ulasan'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }

  // GET /api/marketplace/vouchers
  Future<Map<String, dynamic>> getVouchers() async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak ditemukan'};

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/marketplace/vouchers'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> raw = data['data'] ?? [];
        final vouchers = raw.map((e) => Voucher.fromJson(e)).toList();
        return {'success': true, 'data': vouchers};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil data voucher'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }

  // POST /api/marketplace/orders
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> body) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak ditemukan'};

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/marketplace/orders'),
        headers: _authHeaders(token),
        body: json.encode(body),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data['data'], 'message': data['message']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal membuat pesanan'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }

  // GET /api/marketplace/orders
  Future<Map<String, dynamic>> getOrders() async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak ditemukan'};

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/marketplace/orders'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> raw = data['data'] ?? [];
        final orders = raw.map((e) => Order.fromJson(e)).toList();
        return {'success': true, 'data': orders};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil riwayat transaksi'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }

  // GET /api/marketplace/orders/:id
  Future<Map<String, dynamic>> getOrderById(int id) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak ditemukan'};

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/marketplace/orders/$id'),
        headers: _authHeaders(token),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        final order = Order.fromJson(data['data']);
        return {'success': true, 'data': order};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil detail transaksi'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }
}
