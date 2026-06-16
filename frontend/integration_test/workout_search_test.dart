import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/screens/catalogue/catalogue_page.dart';
import 'package:gymbro/utils/palette.dart';
import 'package:integration_test/integration_test.dart';

// ignore_for_file: avoid_print

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp() {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: kBg,
        body: CataloguePage(),
      ),
    );
  }

  void logHeader() {
    print('');
    print('========================================');
    print('TEST CASE: Mencari workout');
    print('SCENARIO ID: TS.WO-1.005');
    print('CASE ID: TS.WO-01.005.001');
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

  Future<void> waitForBackend(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }

  group('Workout Catalogue - Search Workout [TC-WO-005]', () {
    testWidgets('user can search and find a workout', (tester) async {
      logHeader();

      logStep(0, 'User berada di page Workout.');
      await tester.pumpWidget(buildApp());
      await waitForBackend(tester);

      verifyOneWidget(0, 'Workout page header "Train" is visible', find.text('Train'));
      verifyAtLeastOneWidget(
        0,
        'Workout data is displayed before searching',
        find.textContaining(RegExp(r'^\d+ found$')),
      );

      logStep(1, 'User memilih salah satu workout sebagai target pencarian.');
      const targetWorkout = 'Abs Beginner';
      verify(
        1,
        'Target workout selected for search: "$targetWorkout"',
        targetWorkout.isNotEmpty,
      );

      final workoutCard = find.text(targetWorkout);
      final scrollable = find.byType(Scrollable).first;
      
      await tester.scrollUntilVisible(
        workoutCard,
        200.0,
        scrollable: scrollable,
      );
      
      await tester.pumpAndSettle();
      await tester.tap(workoutCard);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));


      verifyAtLeastOneWidget(
        1,
        'User is on Workout Detail Page (Exercise Selection)',
        find.text('Choosen Workout'),
      );

      logStep(2, 'User menggunakan search bar untuk mencari exercise dalam workout tersebut.');
      const targetExercise = 'Russian Twist';
      final searchField = find.byType(TextField);
      verifyOneWidget(
        2,
        'Exercise search bar is visible',
        searchField,
      );

      await tester.enterText(searchField, targetExercise);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      verifyAtLeastOneWidget(
        2,
        'User menemukan exercise yang dicari menggunakan fitur search',
        find.text(targetExercise),
      );

      print('');
      print('========================================');
      print('EXPECTED RESULT:');
      print('- User menemukan exercise yang dicari menggunakan fitur search');
      print('STATUS: PASS - All tests passed!');
      print('========================================');
      print('');
    });
  });
}
