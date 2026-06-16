// ============================================================
// Test Suite  : TS.AUTH-5.001 - Ubah Foto Profil
// Description : Widget test untuk fitur ubah foto profil
// Tester      : Samuel Armando Napitu
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gymbro/providers/auth_provider.dart';
import 'package:gymbro/models/user_model.dart';
import 'package:gymbro/screens/profile/profile_page.dart';

const String _fakePngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
    '+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

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

  final baseUser = UserModel(
    id: '1',
    fullName: 'Samuel Test',
    email: 'samuel@test.com',
    role: 'user',
  );

  group('TS.AUTH-5.001 - Ubah Foto Profil', () {
    // TC.AUTH-5.001.001 | Positive | EP
    // Avatar default tampil saat belum ada foto profil
    testWidgets('TC.AUTH-5.001.001 - Avatar default tampil saat tidak ada foto profil', (tester) async {
      await tester.pumpWidget(buildApp(baseUser));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    // TC.AUTH-5.001.002 | Positive | EP
    // Ikon kamera tampil dan dapat di-tap
    testWidgets('TC.AUTH-5.001.002 - Ikon kamera tampil dan bisa di-tap', (tester) async {
      await tester.pumpWidget(buildApp(baseUser));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pump();

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    // TC.AUTH-5.001.003 | Positive | EP
    // Avatar menampilkan foto setelah upload berhasil
    testWidgets('TC.AUTH-5.001.003 - CircleAvatar memakai foto saat user sudah upload foto profil', (tester) async {
      final userWithPhoto = baseUser.copyWith(photoUrl: _fakePngBase64);
      await tester.pumpWidget(buildApp(userWithPhoto));
      await tester.pumpAndSettle();

      final hasImage = tester
          .widgetList<CircleAvatar>(find.byType(CircleAvatar))
          .any((a) => a.backgroundImage != null);

      expect(hasImage, isTrue);
      expect(find.byIcon(Icons.person), findsNothing);
    });
  });
}
