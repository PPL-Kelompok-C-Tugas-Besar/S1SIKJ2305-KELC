import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/utils/calorie_calculator.dart';

void main() {
  group('CalorieCalculator', () {
    group('calculateCalories', () {
      test('beginner 30 menit, berat default 70 kg', () {
        // MET 3.5 × 30 menit × 70 kg × 3.5 / 200 = 128.625 → 129
        final result = CalorieCalculator.calculateCalories(
          durationMinutes: 30,
          level: 'beginner',
        );
        expect(result, 129);
      });

      test('intermediate 30 menit, berat default 70 kg', () {
        // MET 5.0 × 30 menit × 70 kg × 3.5 / 200 = 183.75 → 184
        final result = CalorieCalculator.calculateCalories(
          durationMinutes: 30,
          level: 'intermediate',
        );
        expect(result, 184);
      });

      test('advanced 30 menit, berat default 70 kg', () {
        // MET 8.0 × 30 menit × 70 kg × 3.5 / 200 = 294 → 294
        final result = CalorieCalculator.calculateCalories(
          durationMinutes: 30,
          level: 'advanced',
        );
        expect(result, 294);
      });

      test('dengan berat badan kustom 80 kg', () {
        // MET 5.0 × 45 menit × 80 kg × 3.5 / 200 = 315
        final result = CalorieCalculator.calculateCalories(
          durationMinutes: 45,
          level: 'intermediate',
          bodyWeightKg: 80,
        );
        expect(result, 315);
      });

      test('durasi 0 mengembalikan 0', () {
        final result = CalorieCalculator.calculateCalories(
          durationMinutes: 0,
          level: 'beginner',
        );
        expect(result, 0);
      });

      test('durasi negatif mengembalikan 0', () {
        final result = CalorieCalculator.calculateCalories(
          durationMinutes: -10,
          level: 'intermediate',
        );
        expect(result, 0);
      });

      test('level tidak dikenali mengembalikan 0', () {
        final result = CalorieCalculator.calculateCalories(
          durationMinutes: 30,
          level: 'unknown_level',
        );
        expect(result, 0);
      });

      test('case insensitive — "Beginner" sama dengan "beginner"', () {
        final upper = CalorieCalculator.calculateCalories(
          durationMinutes: 30,
          level: 'Beginner',
        );
        final lower = CalorieCalculator.calculateCalories(
          durationMinutes: 30,
          level: 'beginner',
        );
        expect(upper, lower);
      });

      test('berat badan 0 gunakan default', () {
        final withZero = CalorieCalculator.calculateCalories(
          durationMinutes: 30,
          level: 'beginner',
          bodyWeightKg: 0,
        );
        final withDefault = CalorieCalculator.calculateCalories(
          durationMinutes: 30,
          level: 'beginner',
        );
        expect(withZero, withDefault);
      });

      test('berat badan negatif gunakan default', () {
        final withNegative = CalorieCalculator.calculateCalories(
          durationMinutes: 30,
          level: 'beginner',
          bodyWeightKg: -50,
        );
        final withDefault = CalorieCalculator.calculateCalories(
          durationMinutes: 30,
          level: 'beginner',
        );
        expect(withNegative, withDefault);
      });

      test('durasi 1 menit advanced 70 kg', () {
        // MET 8.0 × 1 menit × 70 kg × 3.5 / 200 = 9.8 → 10
        final result = CalorieCalculator.calculateCalories(
          durationMinutes: 1,
          level: 'advanced',
        );
        expect(result, 10);
      });
    });

    group('getMetValue', () {
      test('beginner → 3.5', () {
        expect(CalorieCalculator.getMetValue('beginner'), 3.5);
      });

      test('intermediate → 5.0', () {
        expect(CalorieCalculator.getMetValue('intermediate'), 5.0);
      });

      test('advanced → 8.0', () {
        expect(CalorieCalculator.getMetValue('advanced'), 8.0);
      });

      test('case insensitive', () {
        expect(CalorieCalculator.getMetValue('ADVANCED'), 8.0);
      });

      test('unknown level → null', () {
        expect(CalorieCalculator.getMetValue('expert'), isNull);
      });
    });

    group('supportedLevels', () {
      test('berisi 3 level', () {
        expect(CalorieCalculator.supportedLevels.length, 3);
      });

      test('berisi beginner, intermediate, advanced', () {
        expect(
          CalorieCalculator.supportedLevels,
          containsAll(['beginner', 'intermediate', 'advanced']),
        );
      });
    });
  });
}
