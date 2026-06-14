import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gymbro/screens/E-commerce/catalog_ecommerce.dart';
import 'package:gymbro/screens/E-commerce/cart_ecommerce.dart';
import 'package:gymbro/screens/E-commerce/detailcatalog_ecommerce.dart';
import 'package:provider/provider.dart';
import 'package:gymbro/providers/auth_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // DATA SUMBER
  final productsData = [
    {
      'id': 1,
      'name': 'Optimum Nutrition Whey Protein',
      'price': 450000,
      'stock': 10,
      'image_url': 'https://images-na.ssl-images-amazon.com/images/I/718v7ltAwuL.jpg',
      'description': 'Protein whey premium untuk muscle growth dan recovery',
      'category': 'Protein',
      'weight_grams': 1000
    },
    {
      'id': 2,
      'name': 'Creatine Monohydrate',
      'price': 350000,
      'stock': 11,
      'image_url': 'https://m.media-amazon.com/images/I/51jPe3mKeML._SX300_SY300_QL70_ML2_.jpg',
      'description': 'Meningkatkan strength dan performa latihan',
      'category': 'Performance',
      'weight_grams': 300
    },
    {
      'id': 3,
      'name': 'Pre-Workout Blast',
      'price': 450000,
      'stock': 7,
      'image_url': 'https://i5.walmartimages.com/asr/a6c684eb-a04b-4f64-b839-8b81cbbdec7d_1.e24224343b000955449d00f55ccb9c43.jpeg',
      'description': 'Booster energi sebelum latihan',
      'category': 'Pre-Workout',
      'weight_grams': 400
    },
    {
      'id': 4,
      'name': 'BCAA Plus',
      'price': 300000,
      'stock': 10,
      'image_url': 'https://m.media-amazon.com/images/I/71R5r6mtpzL._AC_SL1500_.jpg',
      'description': 'Membantu recovery dan mengurangi muscle soreness',
      'category': 'Recovery',
      'weight_grams': 250
    },
    {
      'id': 5,
      'name': 'Mass Gainer Extreme',
      'price': 950000,
      'stock': 7,
      'image_url': 'https://m.media-amazon.com/images/I/71KJflkdF6L._AC_SL1500_.jpg',
      'description': 'Menambah massa otot dan berat badan',
      'category': 'Weight Gainer',
      'weight_grams': 3000
    },
    {
      'id': 6,
      'name': 'Pure Glutamine',
      'price': 250000,
      'stock': 8,
      'image_url': 'https://m.media-amazon.com/images/I/71npefQOyVL.jpg',
      'description': 'Support pemulihan otot setelah latihan',
      'category': 'Recovery',
      'weight_grams': 200
    }
  ];

  final cartItemsData = [
    {
      'id': '101',
      'product_id': 1,
      'name': 'Optimum Nutrition Whey Protein',
      'variant': 'Standard',
      'price': 450000,
      'quantity': 1,
      'image': 'https://images-na.ssl-images-amazon.com/images/I/718v7ltAwuL.jpg',
      'stock': 10,
      'selected': true
    }
  ];

  Widget buildApp(Widget home) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        home: home,
      ),
    );
  }


  Future<void> slowPump(WidgetTester tester, {int ms = 600}) async {
    await tester.pump(Duration(milliseconds: ms));
    await tester.pumpAndSettle();
  }

  group(' Catalog & Cart Integration Test ', () {
    testWidgets('Navigate to Detail', (tester) async {
      await tester.pumpWidget(buildApp(ShopPage(manualProducts: productsData)));
      await tester.pumpAndSettle();
      await slowPump(tester);

      final productCard = find.descendant(
        of: find.byType(GridView),
        matching: find.byType(GestureDetector),
      ).first;
      
      await tester.tap(productCard);
      await slowPump(tester);

      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.text('Optimum Nutrition Whey Protein'), findsWidgets);
    });

    testWidgets('Cart Display', (tester) async {
      await tester.pumpWidget(buildApp(CartPage(manualCartItems: cartItemsData)));
      await tester.pump();
      await slowPump(tester);

      expect(find.text('Optimum Nutrition Whey Protein'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('Cart Quantity Update', (tester) async {
      await tester.pumpWidget(buildApp(CartPage(manualCartItems: List.from(cartItemsData))));
      await slowPump(tester);

      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await slowPump(tester);

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('Checkout from Cart', (tester) async {
      await tester.pumpWidget(buildApp(CartPage(manualCartItems: cartItemsData)));
      await slowPump(tester);

      final checkoutButton = find.text('CHECKOUT');
      await tester.tap(checkoutButton);
      await slowPump(tester);

      expect(find.textContaining('ORDER SUMMARY'), findsOneWidget);
    });
  });
}
