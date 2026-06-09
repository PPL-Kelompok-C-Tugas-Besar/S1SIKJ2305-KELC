class UserModel {
  final String id;
  final String fullName;
  final String email;
  final double? weight;
  final String role;
  final String? gender;
  final List<String>? goals;
  final double? targetWeight;
  final bool onboardingCompleted;
  final int weeklyWorkoutGoal;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.weight,
    required this.role,
    this.gender,
    this.goals,
    this.targetWeight,
    this.onboardingCompleted = false,
    this.weeklyWorkoutGoal = 3,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      role: json['role'],
      gender: json['gender'],
      goals: json['goals'] != null ? List<String>.from(json['goals']) : null,
      targetWeight: _parseDouble(json['target_weight']),
      onboardingCompleted: json['onboarding_completed'] == 1 || json['onboarding_completed'] == true,
      weeklyWorkoutGoal: json['weekly_workout_goal'] ?? 3,
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    double? weight,
    String? role,
    String? gender,
    List<String>? goals,
    double? targetWeight,
    bool? onboardingCompleted,
    int? weeklyWorkoutGoal,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      weight: weight ?? this.weight,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      goals: goals ?? this.goals,
      targetWeight: targetWeight ?? this.targetWeight,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      weeklyWorkoutGoal: weeklyWorkoutGoal ?? this.weeklyWorkoutGoal,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}