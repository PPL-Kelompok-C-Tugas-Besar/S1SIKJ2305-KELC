// ============================================================
// Test Suite  : TS.AUTH-2.001 - Login ke Akun
// Description : Widget test untuk fitur login
// Tester      : Samuel Armando Napitu
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gymbro/providers/auth_provider.dart';
import 'package:gymbro/screens/auth/login_screen.dart';

// FakeAuthProvider untuk simulasi login gagal (TC.AUTH-2.001.004)
class FakeFailAuthProvider extends AuthProvider {
  @override
  Future<bool> login({required String email, required String password}) async {
    return false;
  }

  @override
  String? get errorMessage => 'Email atau password salah';
}

void main() {
  Widget buildApp({AuthProvider? provider}) {
    return ChangeNotifierProvider(
      create: (_) => provider ?? AuthProvider(),
      child: MaterialApp(
        routes: {
          '/register': (_) => const Scaffold(body: Text('Register')),
          '/splash': (_) => const Scaffold(body: Text('Splash')),
        },
        home: const LoginScreen(),
      ),
    );
  }

  group('TS.AUTH-2.001 - Login ke Akun', () {
    // TC.AUTH-2.001.001 | Positive | BVA
    // Login dengan kredensial valid — validasi client lulus, request dikirim ke server
    testWidgets('TC.AUTH-2.001.001 - Kredensial valid, validasi client lulus', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'samuel@gmail.com');
      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Email wajib diisi'), findsNothing);
      expect(find.text('Password wajib diisi'), findsNothing);
    });

    // TC.AUTH-2.001.002 | Positive | EP
    // Login role admin — validasi client lulus, routing ditentukan oleh server
    testWidgets('TC.AUTH-2.001.002 - Login role admin, validasi client lulus', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'admin@gymbro.com');
      await tester.enterText(fields.at(1), 'adminpass');

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Email wajib diisi'), findsNothing);
      expect(find.text('Password wajib diisi'), findsNothing);
    });

    // TC.AUTH-2.001.003 | Negative | BVA
    // Field password kosong (empty string boundary)
    testWidgets('TC.AUTH-2.001.003 - Password kosong menampilkan error wajib diisi', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'samuel@gmail.com');

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Password wajib diisi'), findsOneWidget);
    });

    // TC.AUTH-2.001.004 | Negative | EP
    // Password salah — validasi client lulus, server mengembalikan error
    testWidgets('TC.AUTH-2.001.004 - Password salah menampilkan snackbar error dari server', (tester) async {
      await tester.pumpWidget(buildApp(provider: FakeFailAuthProvider()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'samuel@gmail.com');
      await tester.enterText(fields.at(1), 'wrongpass');

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Email atau password salah'), findsOneWidget);
    });
  });
}
