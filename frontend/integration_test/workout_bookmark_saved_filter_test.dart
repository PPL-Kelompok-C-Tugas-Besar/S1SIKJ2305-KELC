import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/screens/catalogue/catalogue_page.dart';
import 'package:gymbro/services/auth_service.dart';
import 'package:gymbro/utils/palette.dart';
import 'package:integration_test/integration_test.dart';

// ignore_for_file: avoid_print

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp() {
    return const MaterialApp(
      home: Scaffold(backgroundColor: kBg, body: CataloguePage()),
    );
  }

  void logHeader() {
    print('');
    print('========================================');
    print('TEST CASE: Bookmark workout');
    print('SCENARIO ID: TS.WO-1.004');
    print('CASE ID: TS.WO-1.004.001');
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

  void verifyAtLeastNWidgets(
    int stepNumber,
    String validation,
    Finder finder,
    int minimum,
  ) {
    final count = finder.evaluate().length;
    verify(stepNumber, '$validation ($count found)', count >= minimum);
  }

  Finder verticalWorkoutScrollable() {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
  }

  int visibleWorkoutCount(WidgetTester tester, int stepNumber) {
    final countFinder = find.textContaining(RegExp(r'^\d+ found$'));
    verifyOneWidget(stepNumber, 'Workout count is displayed', countFinder);

    final countText = tester.widget<Text>(countFinder).data ?? '';
    final count = int.parse(countText.split(' ').first);
    print('  |- [INFO] Current workout count: $countText');
    return count;
  }

  Future<void> waitForBackend(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }

  Future<void> loginAsFreshTestUser() async {
    final authService = AuthService();
    await authService.deleteToken();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'workout.bookmark.$timestamp@test.local';
    const password = 'password123';

    print('  |- [INFO] Creating fresh test user: $email');
    final registerResult = await authService.register(
      fullName: 'Workout Bookmark Tester',
      email: email,
      password: password,
      confirmPassword: password,
    );

    verify(
      0,
      'Fresh test user registration succeeded',
      registerResult['success'] == true,
    );

    final loginResult = await authService.login(
      email: email,
      password: password,
    );
    verify(
      0,
      'Fresh test user login succeeded',
      loginResult['success'] == true,
    );
  }

  Future<void> scrollWorkoutListToTop(WidgetTester tester) async {
    final scrollable = verticalWorkoutScrollable();
    verifyOneWidget(4, 'Vertical workout list is available', scrollable);

    final state = tester.state<ScrollableState>(scrollable);
    while (state.position.extentBefore > 0) {
      await tester.drag(scrollable, const Offset(0, 700));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
    }
  }

  Future<int> bookmarkOneWorkout(WidgetTester tester) async {
    final scrollable = verticalWorkoutScrollable();
    verifyOneWidget(3, 'Vertical workout list is available', scrollable);

    final state = tester.state<ScrollableState>(scrollable);
    var bookmarkTapCount = 0;
    var scrollCount = 0;

    while (bookmarkTapCount < 1) {
      // Find unsaved bookmark icon specifically inside a workout card to avoid the filter section icon
      final unsavedBookmarkIcons = find
          .descendant(
            of: find.byType(
              Container,
            ), // We can use a more specific type if needed, but we'll use find.byIcon with a filter
            matching: find.byIcon(Icons.bookmark_border_rounded),
          )
          .evaluate()
          .where((element) {
            // We ensure it's the 20-sized icon used in the workout card, not the 18-sized one in the filter
            final iconWidget = element.widget as Icon;
            return iconWidget.size == 20;
          })
          .toList();

      if (unsavedBookmarkIcons.isNotEmpty) {
        final targetIcon = find.byWidget(unsavedBookmarkIcons.first.widget);
        await tester.ensureVisible(targetIcon);
        await tester.pumpAndSettle();
        await tester.tap(targetIcon);
        await tester.pump();
        await Future.delayed(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        bookmarkTapCount++;
        print('  |- [PASS] User pressed bookmark icon #$bookmarkTapCount');
        continue;
      }

      if (state.position.extentAfter <= 0) {
        break;
      }

      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      scrollCount++;
    }

    print(
      '  |- [INFO] User pressed $bookmarkTapCount bookmark icons after $scrollCount scroll actions',
    );

    return bookmarkTapCount;
  }

  group('Workout Catalogue - Bookmark Workouts [TC-WO-004]', () {
    testWidgets('user can bookmark one workout and see it with Saved filter', (
      tester,
    ) async {
      logHeader();

      logStep(0, 'Preparing authenticated test user.');
      await loginAsFreshTestUser();

      logStep(1, 'User membuka page workout.');
      await tester.pumpWidget(buildApp());
      await waitForBackend(tester);

      verifyOneWidget(
        1,
        'Workout page header "Train" is visible',
        find.text('Train'),
      );
      final totalWorkoutCount = visibleWorkoutCount(tester, 1);
      verify(
        1,
        'At least one workout exists in catalogue: $totalWorkoutCount found',
        totalWorkoutCount >= 1,
      );
      verifyAtLeastNWidgets(
        1,
        'At least one workout card is visible in current viewport',
        find.byIcon(Icons.arrow_forward_rounded),
        1,
      );

      logStep(2, 'User pilih workout yang ingin di-bookmark.');
      verify(
        2,
        'Catalogue contains enough workouts for bookmark scenario',
        totalWorkoutCount >= 1,
      );

      logStep(3, 'User pencet icon bookmark pada workout yang dipilih.');
      final bookmarkTapCount = await bookmarkOneWorkout(tester);

      logStep(
        4,
        'User melihat semua workout yang di-bookmark dengan filter Saved.',
      );
      await scrollWorkoutListToTop(tester);

      final savedFilter = find.text('Saved').last;
      await tester.ensureVisible(savedFilter);
      await tester.tap(savedFilter);
      await waitForBackend(tester);

      final savedWorkoutCount = visibleWorkoutCount(tester, 4);
      verify(
        4,
        'Bookmark action is complete or saved state already satisfies scenario',
        bookmarkTapCount >= 1 || savedWorkoutCount >= 1,
      );
      verify(
        4,
        'Saved filter shows at least 1 bookmarked workout: $savedWorkoutCount found',
        savedWorkoutCount >= 1,
      );
      verifyAtLeastNWidgets(
        4,
        'At least one saved workout card is visible after selecting Saved filter',
        find.byIcon(Icons.bookmark_rounded),
        1,
      );

      print('');
      print('========================================');
      print('EXPECTED RESULT:');
      print('- User dapat bookmark workout');
      print('- User dapat melihat workout yang telah dibookmark');
      print('STATUS: PASS - All tests passed!');
      print('========================================');
      print('');
    });
  });
}
