import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/screens/E-commerce/detailcatalog_ecommerce.dart';

/// =====================================================
/// Widget Test (Integration-style) - BVA Detail Produk
/// =====================================================
///
/// Menguji UI nyata widget ProductDetailPage secara end-to-end
/// menggunakan WidgetTester (pump, tap, find).
///
/// Stok produk diset = 10 untuk semua skenario.
///
/// Skenario BVA:
///   TC-01: Qty awal = 1, tekan + → tampil 2
///   TC-02: Qty awal = 1, tekan - → tetap 1, snackbar muncul
///   TC-03: Tekan + 4x dari qty 1 → tampil 5 (qty normal, stok cukup)
///   TC-04: Tekan + sampai qty=10, tekan + lagi → snackbar stok habis, qty tetap 10
///   TC-05: Dari qty 5, tekan - → tampil 4
/// =====================================================

void main() {
  /// Helper: Bungkus ProductDetailPage dengan MaterialApp agar widget bisa dirender
  Widget buildPage({required int stock}) {
    return MaterialApp(
      home: ProductDetailPage(
        productName: 'Test Whey Protein',
        imagePath: 'assets/whey.png',
        price: 'Rp 850.000',
        stock: stock,
        weightGrams: 2000,
      ),
    );
  }

  group('Widget Test BVA - Detail Produk (stock = 10)', () {
    testWidgets(
      '[TC-01] Qty awal=1, tekan + → qty menjadi 2 (min boundary berhasil increment)',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildPage(stock: 10));
        await tester.pumpAndSettle();

        // Verifikasi quantity awal = 1
        expect(find.text('1'), findsOneWidget);

        // Tekan tombol +
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Quantity harus menjadi 2
        expect(find.text('2'), findsOneWidget);
      },
    );

    testWidgets(
      '[TC-02] Qty awal=1, tekan - → qty tetap 1 & muncul snackbar "Minimal pembelian 1 item"',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildPage(stock: 10));
        await tester.pumpAndSettle();

        expect(find.text('1'), findsOneWidget);

        // Tekan tombol -
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();

        // Qty tetap 1 (tidak berubah)
        expect(find.text('1'), findsOneWidget);

        // Snackbar peringatan minimal muncul
        expect(find.text('Minimal pembelian 1 item'), findsOneWidget);
      },
    );

    testWidgets(
      '[TC-03] Tekan + 4x dari qty 1 → qty menjadi 5 (normal, stok mencukupi)',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildPage(stock: 10));
        await tester.pumpAndSettle();

        // Tekan + 4 kali
        for (int i = 0; i < 4; i++) {
          await tester.tap(find.byIcon(Icons.add));
          await tester.pump();
        }
        await tester.pumpAndSettle();

        // Qty harus = 5
        expect(find.text('5'), findsOneWidget);
      },
    );

    testWidgets(
      '[TC-04] Tekan + hingga qty=10 (max), tekan + lagi → qty tetap 10 & snackbar stok habis muncul',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildPage(stock: 10));
        await tester.pumpAndSettle();

        // Tekan + 9x → qty = 10 (dari qty awal 1)
        for (int i = 0; i < 9; i++) {
          await tester.tap(find.byIcon(Icons.add));
          await tester.pump();
        }
        await tester.pumpAndSettle();

        expect(find.text('10'), findsOneWidget);

        // Tekan + lagi → melebihi stok
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Qty tidak berubah
        expect(find.text('10'), findsOneWidget);

        // Snackbar stok habis muncul
        expect(
          find.text('Maaf! Stok Test Whey Protein hanya tersisa 10.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '[TC-05] Dari qty=5, tekan - → qty menjadi 4',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildPage(stock: 10));
        await tester.pumpAndSettle();

        // Naikkan ke qty 5 dulu
        for (int i = 0; i < 4; i++) {
          await tester.tap(find.byIcon(Icons.add));
          await tester.pump();
        }
        await tester.pumpAndSettle();
        expect(find.text('5'), findsOneWidget);

        // Tekan - sekali
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();

        // Qty harus = 4
        expect(find.text('4'), findsOneWidget);
      },
    );
  });
}
