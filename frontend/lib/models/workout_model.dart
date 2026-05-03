class Workout {
  final String id;
  final String title;
  final String difficulty;
  final String locationType;
  final String category;
  final String description;
  final int? durationMinutes;
  final int exerciseCount;
  final String equipmentSummary;

  const Workout({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.locationType,
    required this.category,
    required this.description,
    this.durationMinutes,
    required this.exerciseCount,
    required this.equipmentSummary,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: _readString(json, 'id'),
      title: _readString(json, 'title'),
      difficulty: _readString(json, 'difficulty'),
      locationType: _readString(json, 'location_type'),
      category: _readString(json, 'category'),
      description: _readString(json, 'description'),
      durationMinutes: _readInt(json, 'duration_minutes'),
      exerciseCount: _readInt(json, 'exercise_count') ?? 0,
      equipmentSummary: _readString(json, 'equipment_summary'),
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }

  static int? _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
