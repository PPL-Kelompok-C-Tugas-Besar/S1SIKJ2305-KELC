import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gymbro/screens/E-commerce/catalog_ecommerce.dart';
import 'package:gymbro/screens/E-commerce/detailcatalog_ecommerce.dart';
import 'package:provider/provider.dart';
import 'package:gymbro/providers/auth_provider.dart';
import 'package:gymbro/services/auth_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjI2MGYxZmIxLTI4MjUtNDAyOC1hNTAyLTQxZDVjODJlMDA3NSIsImVtYWlsIjoibmNhQGdtYWlsLmNvbSIsInR5cGUiOiJ1c2VyIiwiaWF0IjoxNzc3OTg2OTk3LCJleHAiOjE3ODY2MjY5OTd9.mUwTAnX16Dh7s6zzjU-1o34IAfEOJl2KpUYzThV98FE';

  Widget buildApp(Widget home) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        home: home,
        onGenerateRoute: (settings) {
          if (settings.name == '/shop') {
            return MaterialPageRoute(builder: (_) => const ShopPage());
          }
          return null;
        },
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
  }

  group('Catalog Flow Integration Test', () {
    
    setUp(() async {
      // Pastikan token terinjeksi sebelum tiap test
      await AuthService().saveToken(mockToken);
    });

    testWidgets('[TC-01] Idle -> Product Selected', (tester) async {
      await tester.pumpWidget(buildApp(const ShopPage()));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2)); // Loading data
      await tester.pumpAndSettle();

      final productCard = find.descendant(
        of: find.byType(GridView),
        matching: find.byType(GestureDetector),
      ).first;

      expect(productCard, findsOneWidget);
      await tester.tap(productCard);
      await settle(tester);

      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('[TC-02] Product Selected -> Quantity Updated', (tester) async {
      await tester.pumpWidget(buildApp(const ShopPage()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Masuk ke detail
      await tester.tap(find.descendant(of: find.byType(GridView), matching: find.byType(GestureDetector)).first);
      await settle(tester);

      // Tambah quantity
      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('[TC-03] Quantity Updated -> Added to Cart', (tester) async {
      await tester.pumpWidget(buildApp(const ShopPage()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Masuk ke detail
      await tester.tap(find.descendant(of: find.byType(GridView), matching: find.byType(GestureDetector)).first);
      await settle(tester);

      // Tambah quantity
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Klik Add to Cart
      final addToCartButton = find.text('ADD TO CART');
      await tester.ensureVisible(addToCartButton);
      await tester.tap(addToCartButton);
      await settle(tester);

      // Kembali ke ShopPage
      expect(find.byType(ShopPage), findsOneWidget);
    });

    testWidgets('[TC-04] Product Selected -> Checkout', (tester) async {
      await tester.pumpWidget(buildApp(const ShopPage()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Masuk ke detail
      await tester.tap(find.descendant(of: find.byType(GridView), matching: find.byType(GestureDetector)).first);
      await settle(tester);

      // Klik Purchase
      final purchaseButton = find.text('PURCHASE');
      await tester.ensureVisible(purchaseButton);
      await tester.tap(purchaseButton);
      
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Mendarat di CheckoutPage
      expect(find.textContaining('ORDER SUMMARY'), findsOneWidget);
      expect(find.textContaining('CHECKOUT'), findsWidgets);
      
      // Delay buat liat hasil
      await Future.delayed(const Duration(seconds: 3));
    });
  });
}
