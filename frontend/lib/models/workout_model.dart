class Workout {
  final String id;
  final String title;
  final String difficulty;
  final String locationType;
  final int durationMinutes;

  Workout({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.locationType,
    required this.durationMinutes,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      title: json['title'],
      difficulty: json['difficulty'],
      locationType: json['location_type'],
      durationMinutes: json['duration_minutes'],
    );
  }
}