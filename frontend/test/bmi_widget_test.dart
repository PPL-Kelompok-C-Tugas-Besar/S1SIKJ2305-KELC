// ============================================================
// Test Suite  : TS.AUTH-6.001 - Tampil BMI
// Description : Widget test untuk fitur kalkulasi dan tampilan BMI
// Tester      : Samuel Armando Napitu
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gymbro/providers/auth_provider.dart';
import 'package:gymbro/models/user_model.dart';
import 'package:gymbro/screens/profile/profile_page.dart';

class FakeAuthProvider extends AuthProvider {
  final UserModel _fakeUser;
  FakeAuthProvider(this._fakeUser);

  @override
  UserModel? get user => _fakeUser;
}

void main() {
  Widget buildApp(UserModel user) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: FakeAuthProvider(user),
      child: const MaterialApp(home: Scaffold(body: ProfilePage())),
    );
  }

  group('TS.AUTH-6.001 - Tampil BMI', () {
    // TC.AUTH-6.001.001 | Negative | EP
    // Berat atau tinggi belum diisi
    testWidgets('TC.AUTH-6.001.001 - BMI tampil -- saat berat atau tinggi badan belum diisi', (tester) async {
      final user = UserModel(
        id: '1', fullName: 'Samuel Test', email: 'samuel@test.com', role: 'user',
      );
      await tester.pumpWidget(buildApp(user));
      await tester.pumpAndSettle();

      expect(find.text('--'), findsWidgets);
      expect(find.text('Isi berat & tinggi badan'), findsOneWidget);
    });

    // TC.AUTH-6.001.002 | Positive | BVA
    // BMI = 70 / (1.70^2) = 24.2 → Normal
    testWidgets('TC.AUTH-6.001.002 - Nilai BMI 24.2 dan kategori Normal tampil benar (BB 70kg, TB 170cm)', (tester) async {
      final user = UserModel(
        id: '1', fullName: 'Samuel Test', email: 'samuel@test.com', role: 'user',
        weight: 70.0, height: 170.0,
      );
      await tester.pumpWidget(buildApp(user));
      await tester.pumpAndSettle();

      expect(find.text('24.2'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
    });

    // TC.AUTH-6.001.003 | Positive | BVA
    // BMI = 100 / (1.70^2) = 34.6 → Obesitas
    testWidgets('TC.AUTH-6.001.003 - Nilai BMI 34.6 dan kategori Obesitas tampil benar (BB 100kg, TB 170cm)', (tester) async {
      final user = UserModel(
        id: '1', fullName: 'Samuel Test', email: 'samuel@test.com', role: 'user',
        weight: 100.0, height: 170.0,
      );
      await tester.pumpWidget(buildApp(user));
      await tester.pumpAndSettle();

      expect(find.text('34.6'), findsOneWidget);
      expect(find.text('Obesitas'), findsOneWidget);
    });

    // TC.AUTH-6.001.004 | Positive | BVA
    // BMI = 45 / (1.70^2) = 15.6 → Kekurangan Berat Badan
    testWidgets('TC.AUTH-6.001.004 - Kategori Kekurangan Berat Badan tampil benar (BB 45kg, TB 170cm)', (tester) async {
      final user = UserModel(
        id: '1', fullName: 'Samuel Test', email: 'samuel@test.com', role: 'user',
        weight: 45.0, height: 170.0,
      );
      await tester.pumpWidget(buildApp(user));
      await tester.pumpAndSettle();

      expect(find.text('15.6'), findsOneWidget);
      expect(find.text('Kekurangan Berat Badan'), findsOneWidget);
    });

    // TC.AUTH-6.001.005 | Positive | BVA
    // BMI = 80 / (1.70^2) = 27.7 → Kelebihan Berat Badan
    testWidgets('TC.AUTH-6.001.005 - Kategori Kelebihan Berat Badan tampil benar (BB 80kg, TB 170cm)', (tester) async {
      final user = UserModel(
        id: '1', fullName: 'Samuel Test', email: 'samuel@test.com', role: 'user',
        weight: 80.0, height: 170.0,
      );
      await tester.pumpWidget(buildApp(user));
      await tester.pumpAndSettle();

      expect(find.text('27.7'), findsOneWidget);
      expect(find.text('Kelebihan Berat Badan'), findsOneWidget);
    });
  });
}
