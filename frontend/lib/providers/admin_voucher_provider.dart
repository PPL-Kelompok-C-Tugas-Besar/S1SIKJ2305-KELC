import 'package:flutter/material.dart';
import '../models/voucher_model.dart';
import '../services/admin_service.dart';

class AdminVoucherProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<Voucher> _vouchers = [];
  bool _isLoading = false;
  String? _error;

  List<Voucher> get vouchers => _vouchers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchVouchers({String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _adminService.getAdminVouchers(search: search);

    if (result['success']) {
      _vouchers = result['data'] as List<Voucher>;
    } else {
      _error = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createVoucher(Map<String, dynamic> body) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _adminService.createVoucher(body);

    _isLoading = false;
    if (result['success']) {
      // Re-fetch list
      await fetchVouchers();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVoucher(int id, Map<String, dynamic> body) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _adminService.updateVoucher(id, body);

    _isLoading = false;
    if (result['success']) {
      // Re-fetch list
      await fetchVouchers();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVoucher(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _adminService.deleteVoucher(id);

    _isLoading = false;
    if (result['success']) {
      _vouchers.removeWhere((v) => v.id == id);
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }
}
