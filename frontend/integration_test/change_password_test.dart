// ============================================================
// Test Suite  : TS.AUTH-4.001 - Ubah Password
// Description : Integration test untuk fitur ubah password
// Tester      : Samuel Armando Napitu
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:gymbro/providers/auth_provider.dart';
import 'package:gymbro/screens/profile/change_password_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp() {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MaterialApp(
        home: ChangePasswordScreen(),
      ),
    );
  }

  Future<void> slowPump(WidgetTester tester, {int ms = 400}) async {
    await tester.pump(Duration(milliseconds: ms));
    await tester.pumpAndSettle();
  }

  group('TS.AUTH-4.001 - Ubah Password', () {
    // TC.AUTH-4.001.001 | Positive | BVA
    // Password baru tepat 6 karakter (lower boundary)
    testWidgets('TC.AUTH-4.001.001 - Halaman ubah password tampil dengan benar', (tester) async {
      await tester.pumpWidget(buildApp());
      await slowPump(tester);

      expect(find.text('Ubah Password'), findsWidgets);
      expect(find.text('Password Lama'), findsOneWidget);
      expect(find.text('Password Baru'), findsOneWidget);
      expect(find.text('Konfirmasi Password Baru'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);
    });

    // TC.AUTH-4.001.002 | Negative | BVA
    // Password baru 5 karakter (di bawah lower boundary)
    testWidgets('TC.AUTH-4.001.002 - Password baru kurang dari 6 karakter menampilkan error', (tester) async {
      await tester.pumpWidget(buildApp());
      await slowPump(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'passwordLama123');
      await tester.enterText(fields.at(1), '12345');
      await tester.enterText(fields.at(2), '12345');
      await slowPump(tester);

      await tester.tap(find.text('Simpan'));
      await slowPump(tester);

      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    });

    // TC.AUTH-4.001.003 | Negative | EP
    // Field password lama kosong
    testWidgets('TC.AUTH-4.001.003 - Field password lama kosong menampilkan error', (tester) async {
      await tester.pumpWidget(buildApp());
      await slowPump(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(1), 'abc123');
      await tester.enterText(fields.at(2), 'abc123');
      await slowPump(tester);

      await tester.tap(find.text('Simpan'));
      await slowPump(tester);

      expect(find.text('Password lama wajib diisi'), findsOneWidget);
    });

    // TC.AUTH-4.001.004 | Negative | EP
    // Konfirmasi password tidak cocok
    testWidgets('TC.AUTH-4.001.004 - Konfirmasi password tidak cocok menampilkan error', (tester) async {
      await tester.pumpWidget(buildApp());
      await slowPump(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'passwordLama123');
      await tester.enterText(fields.at(1), 'abc123');
      await tester.enterText(fields.at(2), 'xyz999');
      await slowPump(tester);

      await tester.tap(find.text('Simpan'));
      await slowPump(tester);

      expect(find.text('Konfirmasi password tidak cocok'), findsOneWidget);
    });

    // TC.AUTH-4.001.005 | Negative | EP
    // Password lama salah — validasi lulus di client, error dari server
    testWidgets('TC.AUTH-4.001.005 - Semua field valid, validasi client lulus', (tester) async {
      await tester.pumpWidget(buildApp());
      await slowPump(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'wrongpass123');
      await tester.enterText(fields.at(1), 'newpass123');
      await tester.enterText(fields.at(2), 'newpass123');
      await slowPump(tester);

      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.text('Password lama wajib diisi'), findsNothing);
      expect(find.text('Password baru wajib diisi'), findsNothing);
      expect(find.text('Konfirmasi password tidak cocok'), findsNothing);
      expect(find.text('Password minimal 6 karakter'), findsNothing);
    });
  });
}
