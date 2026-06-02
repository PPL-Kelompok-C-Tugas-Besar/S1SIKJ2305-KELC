// [PKCTB-383] Rumus hitung kalori berdasarkan durasi dan level workout.
//
// Rumus:
//   kalori = durasi (menit) × MET × berat badan (kg) × 3.5 / 200
//
// MET (Metabolic Equivalent of Task) disesuaikan berdasarkan level:
//   - Beginner     → MET 3.5  (latihan ringan, pemanasan)
//   - Intermediate → MET 5.0  (latihan sedang, kardio moderat)
//   - Advanced     → MET 8.0  (latihan berat, HIIT / angkat beban)
//
// Jika berat badan tidak tersedia, digunakan default 70 kg (rata-rata).

class CalorieCalculator {
  CalorieCalculator._(); // prevent instantiation

  /// Default berat badan (kg) jika user belum mengisi profil.
  static const double defaultWeightKg = 70.0;

  /// Mapping level workout → nilai MET.
  static const Map<String, double> _metValues = {
    'beginner': 3.5,
    'intermediate': 5.0,
    'advanced': 8.0,
  };

  /// Menghitung estimasi kalori yang terbakar.
  ///
  /// [durationMinutes] — durasi workout dalam menit.
  /// [level]           — level workout: 'beginner', 'intermediate', atau 'advanced'.
  /// [bodyWeightKg]    — berat badan user dalam kg (opsional, default 70 kg).
  ///
  /// Mengembalikan jumlah kalori (kcal) yang terbakar, dibulatkan ke bilangan bulat.
  /// Mengembalikan 0 jika input tidak valid (durasi ≤ 0 atau level tidak dikenali).
  static int calculateCalories({
    required int durationMinutes,
    required String level,
    double? bodyWeightKg,
  }) {
    if (durationMinutes <= 0) return 0;

    final met = _metValues[level.toLowerCase()];
    if (met == null) return 0;

    final weight = (bodyWeightKg != null && bodyWeightKg > 0)
        ? bodyWeightKg
        : defaultWeightKg;

    // Rumus standar berbasis MET:
    //   kalori = durasi × MET × berat (kg) × 3.5 / 200
    final calories = durationMinutes * met * weight * 3.5 / 200;

    return calories.round();
  }

  /// Helper: mengambil nilai MET berdasarkan level workout.
  /// Mengembalikan null jika level tidak dikenali.
  static double? getMetValue(String level) {
    return _metValues[level.toLowerCase()];
  }

  /// Daftar level workout yang didukung.
  static List<String> get supportedLevels => _metValues.keys.toList();
}
