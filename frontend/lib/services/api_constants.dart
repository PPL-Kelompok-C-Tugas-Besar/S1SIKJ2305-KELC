class ApiConstants {
  // 10.0.2.2 untuk Android emulator, localhost untuk iOS simulator
  static const String baseUrl = 'http://localhost:3000';

  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String profile = '$baseUrl/users/profile';
  static const String history = '$baseUrl/users/history';
  static const String weight = '$baseUrl/users/weight';
  static const String weightHistory = '$baseUrl/users/weight/history';
  static const String workouts = '$baseUrl/workouts';
  static const String exerciseCatalogue =
      '$baseUrl/exercises/exercise-catalogue';
}
