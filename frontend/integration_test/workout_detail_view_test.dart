import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/screens/catalogue/catalogue_page.dart';
import 'package:gymbro/screens/catalogue/exercise_selection_page.dart';
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
    print('TEST CASE: Membuka detail workout');
    print('SCENARIO ID: TS.WO-1.002');
    print('CASE ID: TS.WO-1.002.001');
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

  Finder verticalWorkoutScrollable() {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
  }

  Future<void> scrollUntilWorkoutIsVisible(
    WidgetTester tester,
    String workoutTitle,
  ) async {
    logStep(1, 'Searching workout list for "$workoutTitle"...');

    final scrollable = verticalWorkoutScrollable();
    verifyOneWidget(1, 'Vertical workout list is available', scrollable);

    final targetTitle = find.text(workoutTitle);
    final state = tester.state<ScrollableState>(scrollable);
    var scrollCount = 0;

    while (targetTitle.evaluate().isEmpty && state.position.extentAfter > 0) {
      await tester.drag(scrollable, const Offset(0, -500));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      scrollCount++;
    }

    verify(
      1,
      'Workout "$workoutTitle" is visible after $scrollCount scroll actions',
      targetTitle.evaluate().isNotEmpty,
    );
  }

  Future<void> openAbsBeginnerWorkout(WidgetTester tester) async {
    logStep(1, 'User menekan card workout "Abs Beginner"...');

    await scrollUntilWorkoutIsVisible(tester, 'Abs Beginner');

    final absBeginnerTitle = find.text('Abs Beginner');
    verifyOneWidget(1, 'Workout card title "Abs Beginner" is visible', absBeginnerTitle);

    await tester.ensureVisible(absBeginnerTitle);

    final absBeginnerCard = find.ancestor(
      of: absBeginnerTitle,
      matching: find.byType(GestureDetector),
    );
    verifyAtLeastOneWidget(1, 'Tap target for "Abs Beginner" card is found', absBeginnerCard);

    await tester.tap(absBeginnerCard.first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    verify(1, 'User tapped "Abs Beginner" card', true);
  }

  group('Workout Catalogue - View Workout Detail [TC-WO-002]', () {
    testWidgets('user can open Abs Beginner workout detail and view exercises', (
      tester,
    ) async {
      logHeader();

      logStep(0, 'Initializing CataloguePage and waiting for workout data...');
      await tester.pumpWidget(buildApp());
      await waitForBackend(tester);

      verifyOneWidget(0, 'Workout page header "Train" is visible', find.text('Train'));
      verifyOneWidget(0, 'Workout section "Workouts" is visible', find.text('Workouts'));
      verifyAtLeastOneWidget(
        0,
        'Workout count is displayed',
        find.textContaining(RegExp(r'^\d+ found$')),
      );

      await openAbsBeginnerWorkout(tester);

      logStep(2, 'Verifying navigation to exercise detail page...');
      verifyOneWidget(
        2,
        'User is redirected to ExerciseSelectionPage',
        find.byType(ExerciseSelectionPage),
      );

      logStep(3, 'Verifying selected workout title is displayed...');
      verifyAtLeastOneWidget(
        3,
        'Selected workout title "Abs Beginner" is displayed',
        find.text('Abs Beginner'),
      );
      verifyAtLeastOneWidget(
        3,
        'Detail page heading is displayed',
        find.textContaining(RegExp(r'Choosen Workout|Chosen Workout')),
      );

      logStep(4, 'Verifying exercises for selected workout are displayed...');
      verifyOneWidget(
        4,
        'Exercise search field is visible',
        find.text('Search exercises'),
      );
      verify(
        4,
        'Exercise list is not empty',
        find.text('No exercises found').evaluate().isEmpty,
      );
      verifyAtLeastOneWidget(
        4,
        'Exercise card content is visible',
        find.byIcon(Icons.fitness_center),
      );

      logStep(5, 'Verifying session action is available...');
      verifyOneWidget(
        5,
        '"Start Session" button is visible',
        find.text('Start Session'),
      );

      print('');
      print('========================================');
      print('EXPECTED RESULT:');
      print('- User diarahkan ke halaman detail exercise');
      print('- Judul workout yang dipilih tampil');
      print('- Exercise yang muncul sesuai workout tersebut');
      print('STATUS: PASS - All tests passed!');
      print('========================================');
      print('');
    });
  });
}
