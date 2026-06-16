// ============================================================
// Test Suite  : TS.AUTH-1.001 - Registrasi Akun Baru
// Description : Widget test untuk fitur registrasi akun
// Tester      : Samuel Armando Napitu
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gymbro/providers/auth_provider.dart';
import 'package:gymbro/screens/auth/register_screen.dart';

void main() {
  Widget buildApp() {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        routes: {
          '/login': (_) => const Scaffold(body: Text('Login Page')),
        },
        home: const RegisterScreen(),
      ),
    );
  }

  group('TS.AUTH-1.001 - Registrasi Akun Baru', () {
    // TC.AUTH-1.001.001 | Positive | BVA
    // Password tepat 6 karakter (lower boundary) — validasi client lulus
    testWidgets('TC.AUTH-1.001.001 - Semua field valid dengan password 6 karakter, validasi lulus', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Samuel');
      await tester.enterText(fields.at(1), 'samuel@gmail.com');
      await tester.enterText(fields.at(2), '123456');
      await tester.enterText(fields.at(3), '123456');

      await tester.tap(find.text('Daftar'));
      await tester.pump();

      expect(find.text('Nama lengkap wajib diisi'), findsNothing);
      expect(find.text('Format email tidak valid'), findsNothing);
      expect(find.text('Password minimal 6 karakter'), findsNothing);
      expect(find.text('Password tidak cocok'), findsNothing);
    });

    // TC.AUTH-1.001.002 | Negative | BVA
    // Password 5 karakter (di bawah lower boundary)
    testWidgets('TC.AUTH-1.001.002 - Password 5 karakter menampilkan error minimal 6 karakter', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Samuel');
      await tester.enterText(fields.at(1), 'samuel@gmail.com');
      await tester.enterText(fields.at(2), '12345');
      await tester.enterText(fields.at(3), '12345');

      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    });

    // TC.AUTH-1.001.003 | Negative | EP
    // Format email tidak valid (tanpa karakter @)
    testWidgets('TC.AUTH-1.001.003 - Email tanpa @ menampilkan error format tidak valid', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Samuel');
      await tester.enterText(fields.at(1), 'samuelgmail.com');
      await tester.enterText(fields.at(2), '123456');
      await tester.enterText(fields.at(3), '123456');

      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Format email tidak valid'), findsOneWidget);
    });

    // TC.AUTH-1.001.004 | Negative | EP
    // Konfirmasi password tidak cocok
    testWidgets('TC.AUTH-1.001.004 - Konfirmasi password berbeda menampilkan error tidak cocok', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Samuel');
      await tester.enterText(fields.at(1), 'samuel@gmail.com');
      await tester.enterText(fields.at(2), '123456');
      await tester.enterText(fields.at(3), 'xyz999');

      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Password tidak cocok'), findsOneWidget);
    });

    // TC.AUTH-1.001.005 | Negative | EP
    // Email sudah terdaftar — validasi client lulus, error dikembalikan server
    testWidgets('TC.AUTH-1.001.005 - Email sudah terdaftar, validasi client lulus', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Samuel');
      await tester.enterText(fields.at(1), 'samuel@gmail.com');
      await tester.enterText(fields.at(2), '123456');
      await tester.enterText(fields.at(3), '123456');

      await tester.tap(find.text('Daftar'));
      await tester.pump();

      expect(find.text('Format email tidak valid'), findsNothing);
      expect(find.text('Password minimal 6 karakter'), findsNothing);
      expect(find.text('Password tidak cocok'), findsNothing);
    });
  });
}
