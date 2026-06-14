import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/models/workout_model.dart';
import 'package:gymbro/screens/catalogue/dynamic_session_page.dart';
import 'package:gymbro/screens/catalogue/exercise_selection_page.dart';
import 'package:gymbro/utils/palette.dart';
import 'package:integration_test/integration_test.dart';

// ignore_for_file: avoid_print

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final selectedWorkout = Workout(
    id: 'wk-001',
    title: 'Abs Beginner',
    difficulty: 'beginner',
    locationType: 'home',
    category: 'workout',
    description:
        'A quick and effective core workout requiring no equipment. Perfect for starting your fitness journey.',
    durationMinutes: 15,
    exerciseCount: 3,
    equipmentSummary: 'None',
    fitnessGoal: 'weight_loss',
    caloriesBurned: 120.5,
  );

  Widget buildApp() {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: kBg,
        body: ExerciseSelectionPage(
          workoutId: selectedWorkout.id,
          location: selectedWorkout.locationType,
          workoutType: selectedWorkout.title,
          workout: selectedWorkout,
        ),
      ),
    );
  }

  void logHeader() {
    print('');
    print('========================================');
    print('TEST CASE: Memulai sesi workout');
    print('SCENARIO ID: TS.WO-1.003');
    print('CASE ID: TS.WO-1.003.001');
    print('TYPE: Positive');
    print('========================================');
    print('');
  }

  void logStep(int stepNumber, String description) {
    print('Step $stepNumber: $description');
  }

  void verify(int stepNumber, String validation, bool passed) {
    final status = passed ? '[PASS]' : '[FAIL]';
    print('  |- $status $validation');
    expect(passed, isTrue, reason: validation);
  }

  void verifyOneWidget(int stepNumber, String validation, Finder finder) {
    final count = finder.evaluate().length;
    verify(stepNumber, '$validation ($count found)', count == 1);
  }

  void verifyAtLeastOneWidget(int stepNumber, String validation, Finder finder) {
    final count = finder.evaluate().length;
    verify(stepNumber, '$validation ($count found)', count > 0);
  }

  Future<void> waitForExercisePageLoad(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }

  group('Workout Session - Start Session From Detail [TC-WO-003]', () {
    testWidgets('user can start workout session from exercise detail page', (
      tester,
    ) async {
      logHeader();

      print('PRE-CONDITION: User berada di halaman Exercise');
      await tester.pumpWidget(buildApp());
      await waitForExercisePageLoad(tester);

      logStep(1, 'User membuka detail workout.');
      verifyAtLeastOneWidget(
        1,
        'Exercise detail page is displayed',
        find.byType(ExerciseSelectionPage),
      );
      verifyAtLeastOneWidget(
        1,
        'Selected workout title "Abs Beginner" is displayed',
        find.text('Abs Beginner'),
      );
      verifyOneWidget(
        1,
        'Start Session button is available',
        find.text('Start Session'),
      );

      logStep(2, 'User menekan tombol Start Session.');
      await tester.tap(find.text('Start Session'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      verify(
        2,
        'Tombol Start Session dapat ditekan dan sistem memberi feedback',
        find.byType(DynamicSessionPage).evaluate().isNotEmpty,
      );
      verifyAtLeastOneWidget(
        2,
        'Workout session page shows active session feedback',
        find.byType(LinearProgressIndicator),
      );

      print('');
      print('========================================');
      print('EXPECTED RESULT:');
      print('- Tombol Start Session dapat ditekan');
      print('- Sistem memberi feedback setelah tombol ditekan');
      print('STATUS: PASS - All tests passed!');
      print('========================================');
      print('');
    });
  });
}
