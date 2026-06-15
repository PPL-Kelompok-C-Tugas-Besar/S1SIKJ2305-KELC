import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/admin_service.dart';
import '../models/master_exercise_model.dart';

class ExerciseUploadProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  final ImagePicker _picker = ImagePicker();

  String _namaLatihan = '';
  String _tipe = 'Gym';
  String _targetOtot = 'Upper body';
  String _deskripsiTeknis = '';
  File? _selectedMedia;
  XFile? _selectedXFile;
  Uint8List? _webImageBytes;
  bool _isLoading = false;

  // Getters
  String get namaLatihan => _namaLatihan;
  String get tipe => _tipe;
  String get targetOtot => _targetOtot;
  String get deskripsiTeknis => _deskripsiTeknis;
  File? get selectedMedia => _selectedMedia;
  XFile? get selectedXFile => _selectedXFile;
  Uint8List? get webImageBytes => _webImageBytes;
  bool get isLoading => _isLoading;

  // Setters
  void setNamaLatihan(String val) => _namaLatihan = val;
  void setTipe(String val) {
    _tipe = val;
    notifyListeners();
  }
  void setTargetOtot(String val) {
    _targetOtot = val;
    notifyListeners();
  }
  void setDeskripsi(String val) => _deskripsiTeknis = val;

  Future<void> pickMedia(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (file != null) {
      _selectedXFile = file;
      if (kIsWeb) {
        _webImageBytes = await file.readAsBytes();
      } else {
        _selectedMedia = File(file.path);
      }
      notifyListeners();
    }
  }

  void clearMedia() {
    _selectedMedia = null;
    _selectedXFile = null;
    _webImageBytes = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> uploadExercise() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Create Exercise Record
      final exerciseData = {
        'name': _namaLatihan,
        'instructions': _deskripsiTeknis,
        'equipment_required': '$_tipe - $_targetOtot',
        'base_calories_burn': 100,
      };

      final createResult = await _adminService.createExercise(exerciseData);
      if (!createResult['success']) {
        _isLoading = false;
        notifyListeners();
        return createResult;
      }

      final MasterExercise newExercise = MasterExercise.fromJson(createResult['data']);

      // 2. If media is selected, upload it
      final hasMedia = kIsWeb ? _webImageBytes != null : _selectedMedia != null;
      if (hasMedia) {
        final uploadResult = await _adminService.uploadExerciseMedia(
          newExercise.id,
          _selectedMedia?.path ?? '',
          bytes: _webImageBytes,
          filename: _selectedXFile?.name,
        );
        if (!uploadResult['success']) {
          _isLoading = false;
          notifyListeners();
          return {'success': true, 'message': 'Latihan dibuat, tapi media gagal diupload: ${uploadResult['message']}'};
        }
      }

      _isLoading = false;
      resetForm();
      notifyListeners();
      return {'success': true, 'message': 'Latihan dan media berhasil diupload!'};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  void resetForm() {
    _namaLatihan = '';
    _tipe = 'Gym';
    _targetOtot = 'Upper body';
    _deskripsiTeknis = '';
    _selectedMedia = null;
    _selectedXFile = null;
    _webImageBytes = null;
    _isLoading = false;
  }
}
