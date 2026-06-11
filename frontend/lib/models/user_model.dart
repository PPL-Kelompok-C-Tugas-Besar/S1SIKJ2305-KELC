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
  final String? photoUrl;
  final double? height;
  final int? age;
  final String? activityLevel;
  final String? dietGoal;
  final int? dailyCalorieTarget;

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
    this.photoUrl,
    this.height,
    this.age,
    this.activityLevel,
    this.dietGoal,
    this.dailyCalorieTarget,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      weight: _parseDouble(json['weight']),
      role: json['role'],
      gender: json['gender'],
      goals: json['goals'] != null ? List<String>.from(json['goals']) : null,
      targetWeight: _parseDouble(json['target_weight']),
      onboardingCompleted: json['onboarding_completed'] == 1 || json['onboarding_completed'] == true,
      weeklyWorkoutGoal: json['weekly_workout_goal'] ?? 3,
      photoUrl: json['photo_url'],
      height: _parseDouble(json['height']),
      age: json['age'] is int ? json['age'] : int.tryParse(json['age']?.toString() ?? ''),
      activityLevel: json['activity_level'],
      dietGoal: json['diet_goal'],
      dailyCalorieTarget: json['daily_calorie_target'] is int ? json['daily_calorie_target'] : int.tryParse(json['daily_calorie_target']?.toString() ?? ''),
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
    String? photoUrl,
    double? height,
    int? age,
    String? activityLevel,
    String? dietGoal,
    int? dailyCalorieTarget,
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
      photoUrl: photoUrl ?? this.photoUrl,
      height: height ?? this.height,
      age: age ?? this.age,
      activityLevel: activityLevel ?? this.activityLevel,
      dietGoal: dietGoal ?? this.dietGoal,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}