import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gymbro/screens/E-commerce/detailcatalog_ecommerce.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  /// Helper delay biar konsisten
  Future<void> slowPump(WidgetTester tester,
      {int ms = 600}) async {
    await tester.pump(Duration(milliseconds: ms));
  }

  group('Integration Test BVA - Detail Produk (stock = 10)', () {

    testWidgets('[TC-01]', (tester) async {
      await tester.pumpWidget(buildPage(stock: 10));
      await slowPump(tester, ms: 1000);

      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await slowPump(tester);

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('[TC-02]', (tester) async {
      await tester.pumpWidget(buildPage(stock: 10));
      await slowPump(tester, ms: 1000);

      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await slowPump(tester);

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Minimal pembelian 1 item'), findsOneWidget);
    });

    testWidgets('[TC-03]', (tester) async {
      await tester.pumpWidget(buildPage(stock: 10));
      await slowPump(tester, ms: 1000);

      for (int i = 0; i < 4; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await slowPump(tester, ms: 400);
      }

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('[TC-04]', (tester) async {
      await tester.pumpWidget(buildPage(stock: 10));
      await slowPump(tester, ms: 1000);

      for (int i = 0; i < 9; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await slowPump(tester, ms: 300);
      }

      expect(find.text('10'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await slowPump(tester);

      expect(find.text('10'), findsOneWidget);
      expect(
        find.text('Maaf! Stok Test Whey Protein hanya tersisa 10.'),
        findsOneWidget,
      );
    });

    testWidgets('[TC-05]', (tester) async {
      await tester.pumpWidget(buildPage(stock: 10));
      await slowPump(tester, ms: 1000);

      for (int i = 0; i < 4; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await slowPump(tester, ms: 300);
      }

      expect(find.text('5'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await slowPump(tester);

      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('[TC-06]', (tester) async {
      await tester.pumpWidget(buildPage(stock: 10));
      await slowPump(tester, ms: 1000);

      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await slowPump(tester);

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('[TC-07]', (tester) async {
      await tester.pumpWidget(buildPage(stock: 10));
      await slowPump(tester, ms: 1000);

      await tester.tap(find.byIcon(Icons.add));
      await slowPump(tester);

      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await slowPump(tester);

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('[TC-08]', (tester) async {
      await tester.pumpWidget(buildPage(stock: 10));
      await slowPump(tester, ms: 1000);

      for (int i = 0; i < 9; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await slowPump(tester, ms: 300);
      }

      expect(find.text('10'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await slowPump(tester);

      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('[TC-09]', (tester) async {
      await tester.pumpWidget(buildPage(stock: 10));
      await slowPump(tester, ms: 1000);

      for (int i = 0; i < 4; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await slowPump(tester, ms: 300);
      }

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('[TC-10]', (tester) async {
      await tester.pumpWidget(buildPage(stock: 10));
      await slowPump(tester, ms: 1000);

      for (int i = 0; i < 8; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await slowPump(tester, ms: 300);
      }

      expect(find.text('9'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await slowPump(tester);

      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('[TC-11]', (tester) async {
      await tester.pumpWidget(buildPage(stock: 10));
      await slowPump(tester, ms: 1000);

      for (int i = 0; i < 9; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await slowPump(tester, ms: 300);
      }

      expect(find.text('10'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await slowPump(tester);

      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('[TC-12]', (tester) async {
      await tester.pumpWidget(buildPage(stock: 10));
      await slowPump(tester, ms: 1000);

      for (int i = 0; i < 9; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await slowPump(tester, ms: 300);
      }

      await tester.tap(find.byIcon(Icons.add));
      await slowPump(tester);

      expect(
        find.text('Maaf! Stok Test Whey Protein hanya tersisa 10.'),
        findsOneWidget,
      );
    });
  });
}