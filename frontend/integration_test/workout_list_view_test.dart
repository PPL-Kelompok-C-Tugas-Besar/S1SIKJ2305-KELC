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

  void logStep(int stepNumber, String description) {
    print('Step $stepNumber: $description');
  }

  void logValidation(int stepNumber, String validation, bool passed) {
    final status = passed ? '✓ PASS' : '✗ FAIL';
    print('  └─ [$status] $validation');
  }

  Future<void> waitForCatalogueLoad(WidgetTester tester) async {
    logStep(0, 'Initializing CataloguePage and waiting for content to load...');
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    logValidation(0, 'CataloguePage loaded successfully', true);
  }

  int visibleWorkoutCount(WidgetTester tester) {
    final countFinder = find.textContaining(RegExp(r'^\d+ found$'));
    expect(countFinder, findsOneWidget);

    final countText = tester.widget<Text>(countFinder).data ?? '';
    final count = int.parse(countText.split(' ').first);
    logValidation(1, 'Workout count displayed: "$countText"', true);
    return count;
  }

  Future<void> scrollWorkoutListToBottom(WidgetTester tester) async {
    logStep(3, 'Scrolling workout list to bottom to verify all items are accessible...');
    final scrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    expect(scrollable, findsOneWidget);
    logValidation(3, 'Scrollable workout list found', true);

    final state = tester.state<ScrollableState>(scrollable);
    int scrollCount = 0;

    for (var i = 0; i < 20 && state.position.extentAfter > 0; i++) {
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      scrollCount++;
    }

    expect(state.position.extentAfter, 0);
    logValidation(3, 'Scrolled to bottom after $scrollCount scroll actions', true);
  }

  group('Workout Catalogue - View Workout List [TC-WO-001]', () {
    testWidgets('user can see the list of workouts', (tester) async {
      print('\n========================================');
      print('TEST CASE: Lihat list workout');
      print('SCENARIO ID: TS.WO-1.001');
      print('CASE ID: TC.WO-1.001.001');
      print('TYPE: Positive');
      print('========================================\n');

      // Step 0: Initialize
      await tester.pumpWidget(buildApp());
      await waitForCatalogueLoad(tester);

      // Step 1: Verify UI Elements
      print('\nStep 1: Verifying core UI elements are displayed...');

      final trainHeaderExists = find.text('Train').evaluate().isNotEmpty;
      expect(trainHeaderExists, true);
      logValidation(1, 'Header "Train" is visible', trainHeaderExists);

      final instructionExists =
          find.text('What do you want to focus on today?').evaluate().isNotEmpty;
      expect(instructionExists, true);
      logValidation(1, 'Instruction text is visible', instructionExists);

      final workoutsTabExists = find.text('Workouts').evaluate().isNotEmpty;
      expect(workoutsTabExists, true);
      logValidation(1, 'Workouts tab is visible', workoutsTabExists);

      // Step 2: Verify Workout Data
      print('\nStep 2: Verifying workout data from database...');

      final workoutCount = visibleWorkoutCount(tester);
      expect(workoutCount, greaterThan(0));
      logValidation(2, 'Workout count greater than 0: $workoutCount workouts found', true);

      final arrowsExist = find.byIcon(Icons.arrow_forward_rounded).evaluate().isNotEmpty;
      expect(arrowsExist, true);
      logValidation(2, 'Workout cards display navigation arrows', arrowsExist);

      // Step 3: Verify Scrolling
      await scrollWorkoutListToBottom(tester);
      final arrowsAfterScroll =
          find.byIcon(Icons.arrow_forward_rounded).evaluate().isNotEmpty;
      expect(arrowsAfterScroll, true);
      logValidation(3, 'Workout cards remain accessible after scrolling', arrowsAfterScroll);

      print('\n========================================');
      print('EXPECTED RESULT: User can see workout list with card details (name, category, difficulty, duration)');
      print('STATUS: ✓ PASS - All tests passed!');
      print('========================================\n');
    });
  });
}
