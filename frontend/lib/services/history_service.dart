import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/history_model.dart';
import 'api_constants.dart';

class HistoryService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  Future<String?> _getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<WorkoutHistory>> getHistory() async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.history),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success']) {
          List<dynamic> data = body['data'];
          return data.map((json) => WorkoutHistory.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> addHistory({
    required String workoutName,
    required int durationMinutes,
    required int caloriesBurned,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.history),
        headers: _headers(token),
        body: jsonEncode({
          'workout_name': workoutName,
          'duration_minutes': durationMinutes,
          'calories_burned': caloriesBurned,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
