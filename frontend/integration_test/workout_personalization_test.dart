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
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const Scaffold(backgroundColor: kBg, body: CataloguePage()),
      },
    );
  }

  void logHeader() {
    print('');
    print('========================================');
    print('TEST CASE: System rekomendasi workout berdasarkan aktivitas user');
    print('SCENARIO ID: TS.WO-1.006');
    print('CASE ID: TS.WO-01.006.001');
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
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> loginAsFreshTestUser() async {
    final authService = AuthService();
    await authService.deleteToken();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'workout.recommend.$timestamp@test.local';
    const password = 'password123';

    print('  |- [INFO] Creating fresh test user: $email');
    final registerResult = await authService.register(
      fullName: 'Workout Recommend Tester',
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

    // Update weight so calorie calculation works
    await authService.updateWeight(70.0, DateTime.now());
  }

  group('Workout Catalogue - Personalization [TC-WO-006]', () {
    testWidgets('user gets recommended workout after completing one', (tester) async {
      logHeader();

      logStep(0, 'Preparing authenticated test user with weight set.');
      await loginAsFreshTestUser();
      
      await tester.pumpWidget(buildApp());
      await waitForBackend(tester);

      logStep(1, 'User memilih workout');
      const targetWorkout = 'Powerlifting Basics'; // Has 2 reps-based exercises, easy to skip
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

      verifyOneWidget(
        1,
        'User is on Workout Detail Page',
        find.text('Choosen Workout'),
      );

      logStep(2, 'User melakukan workout sampai selesai');
      // Tap Start Session
      final startButton = find.text('Start Session');
      await tester.tap(startButton);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // In DynamicSessionPage for Powerlifting Basics:
      // Exercise 1: Barbell Squat (reps)
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Tap SELESAI REPS
      final selesaiRepsButton1 = find.text('SELESAI REPS');
      await tester.ensureVisible(selesaiRepsButton1);
      await tester.pumpAndSettle();
      await tester.tap(selesaiRepsButton1);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Rest phase -> Tap MULAI LATIHAN
      final mulaiLatihanButton = find.text('MULAI LATIHAN →');
      await tester.ensureVisible(mulaiLatihanButton);
      await tester.pumpAndSettle();
      await tester.tap(mulaiLatihanButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Exercise 2: Russian Twist (reps)
      final selesaiRepsButton2 = find.text('SELESAI REPS');
      await tester.ensureVisible(selesaiRepsButton2);
      await tester.pumpAndSettle();
      await tester.tap(selesaiRepsButton2);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Finished view -> Tap Selanjutnya
      final selanjutnyaButton = find.text('Selanjutnya');
      await tester.tap(selanjutnyaButton);
      await tester.pump();
      
      // Wait for backend to calculate calories and save history
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      verifyOneWidget(
        2,
        'User is on Workout Summary Screen',
        find.text('Latihan Selesai!'),
      );

      logStep(3, 'User kembali ke page workout');
      final backButton = find.text('Kembali ke Beranda');
      await tester.tap(backButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await waitForBackend(tester);

      verifyOneWidget(
        3,
        'User is back on Catalogue Page',
        find.text('Train'),
      );

      logStep(4, 'User menekan filter Recommended');
      final personalizedFilter = find.text('Recommended');
      await tester.tap(personalizedFilter);
      await tester.pump();
      await waitForBackend(tester);

      verifyAtLeastOneWidget(
        4,
        'System merekomendasi workout yang cocok untuk user',
        find.byIcon(Icons.auto_awesome),
      );

      print('');
      print('========================================');
      print('EXPECTED RESULT:');
      print('- System merekomendasi workout yang cocok untuk user');
      print('STATUS: PASS - All tests passed!');
      print('========================================');
      print('');
    });
  });
}
