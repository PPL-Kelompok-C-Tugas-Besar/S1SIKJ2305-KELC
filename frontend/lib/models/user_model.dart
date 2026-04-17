class UserModel {
  final String id;
  final String fullName;
  final String email;
  final double? weight;
  final String role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.weight,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      role: json['role'],
    );
  }
}