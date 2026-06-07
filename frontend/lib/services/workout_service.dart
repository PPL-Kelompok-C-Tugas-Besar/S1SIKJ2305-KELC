import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/workout_model.dart';
import 'api_constants.dart';

class WorkoutService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  Future<String?> _getToken() async => await _storage.read(key: _tokenKey);

  Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<Workout>> getWorkouts({
    String location = 'all',
    String category = 'all',
  }) async {
    try {
      final uri = Uri.parse(ApiConstants.workouts).replace(
        queryParameters: {
          'location': location,
          'category': category,
        },
      );

      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      final raw = body is List ? body : body['data'];
      if (raw is! List) return [];

      return raw
          .whereType<Map<String, dynamic>>()
          .map(Workout.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Set<String>> getSavedWorkoutIds() async {
    final token = await _getToken();
    if (token == null) return {};

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.workouts}/saved'),
        headers: _authHeaders(token),
      );
      if (response.statusCode != 200) return {};

      final body = jsonDecode(response.body);
      final raw = body['data'];
      if (raw is! List) return {};

      return raw.map((id) => id.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<bool> saveWorkout(String workoutId) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.workouts}/$workoutId/save'),
        headers: _authHeaders(token),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unsaveWorkout(String workoutId) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.workouts}/$workoutId/save'),
        headers: _authHeaders(token),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
