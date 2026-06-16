// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN SYSTEM
// ─────────────────────────────────────────────────────────────────────────────
class _AppColors {
  static const Color bgColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF292929);
  static const Color accentColor = Color(0xFFCCFF00);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK CART PAGE  ──  UI tiruan dari cart_ecommerce.dart
// ─────────────────────────────────────────────────────────────────────────────
class _MockCartPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialItems;
  final int maxStock;
  const _MockCartPage({required this.initialItems, this.maxStock = 10});

  @override
  State<_MockCartPage> createState() => _MockCartPageState();
}

class _MockCartPageState extends State<_MockCartPage> {
  late List<Map<String, dynamic>> cartItems;

  @override
  void initState() {
    super.initState();
    cartItems = widget.initialItems.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  String formatRupiah(int n) {
    final s = n.toString();
    String r = '';
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) r += '.';
      r += s[i];
    }
    return 'Rp $r';
  }

  int get subtotal => cartItems.fold(
        0,
        (sum, item) =>
            item['selected'] == true ? sum + (item['price'] as int) * (item['quantity'] as int) : sum,
      );

  int get shippingCost => subtotal > 0 ? 50000 : 0;
  int get totalCost => subtotal + shippingCost;

  void updateQuantity(int index, int delta) {
    final current = cartItems[index]['quantity'] as int;
    final next = current + delta;

    if (next <= 0) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Minimal pembelian 1 item',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (next > widget.maxStock) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Stok maksimal ${widget.maxStock} item',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => cartItems[index]['quantity'] = next);
  }

  void removeItem(int index) {
    setState(() => cartItems.removeAt(index));
  }

  void toggleSelection(int index, bool? value) {
    setState(() => cartItems[index]['selected'] = value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _AppColors.textPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('SHOP',
                style: TextStyle(
                    color: _AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0)),
            Text('CART',
                style: TextStyle(
                    color: _AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 24)),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.shopping_cart_outlined, size: 80, color: _AppColors.textSecondary),
                          SizedBox(height: 16),
                          Text('Your cart is empty',
                              style: TextStyle(
                                  color: _AppColors.textSecondary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (_, idx) => _buildCartItem(cartItems[idx], idx),
                    ),
            ),
            // Bottom Summary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _AppColors.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal',
                          style: TextStyle(color: _AppColors.textSecondary, fontSize: 16)),
                      Text(formatRupiah(subtotal),
                          style: const TextStyle(
                              color: _AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Shipping',
                          style: TextStyle(color: _AppColors.textSecondary, fontSize: 16)),
                      Text(formatRupiah(shippingCost),
                          style: const TextStyle(
                              color: _AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: _AppColors.textSecondary, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              color: _AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900)),
                      Text(formatRupiah(totalCost),
                          style: const TextStyle(
                              color: _AppColors.accentColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('checkout_button'),
                      onPressed: null, // BVA test tidak butuh navigasi checkout
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.accentColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('CHECKOUT',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item['selected'] == true
              ? _AppColors.accentColor.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: item['selected'] ?? false,
            onChanged: (v) => toggleSelection(index, v),
            activeColor: _AppColors.accentColor,
            checkColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                color: _AppColors.bgColor, borderRadius: BorderRadius.circular(12)),
            child: const Center(
              child: Icon(Icons.fitness_center, color: _AppColors.textSecondary, size: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'],
                    style: const TextStyle(
                        color: _AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(item['variant'] ?? 'Standard',
                    style: const TextStyle(color: _AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatRupiah(item['price'] as int),
                        style: const TextStyle(
                            color: _AppColors.accentColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 16)),
                    // Quantity Control
                    Container(
                      decoration: BoxDecoration(
                          color: _AppColors.bgColor, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          InkWell(
                            key: Key('btn_minus_$index'),
                            onTap: () => updateQuantity(index, -1),
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Icon(Icons.remove, size: 16, color: _AppColors.textPrimary),
                            ),
                          ),
                          Text(
                            '${item['quantity']}',
                            key: Key('qty_text_$index'),
                            style: const TextStyle(
                                color: _AppColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                            key: Key('btn_plus_$index'),
                            onTap: () => updateQuantity(index, 1),
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Icon(Icons.add, size: 16, color: _AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                key: Key('btn_delete_$index'),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                onPressed: () => removeItem(index),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.only(bottom: 40, left: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TEST RUNNER  ──  TS.SP-4: BVA Quantity Cart
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp(Widget home) => MaterialApp(home: home);

  Future<void> pump(WidgetTester t, {int ms = 500}) async {
    await t.pump(Duration(milliseconds: ms));
    await t.pumpAndSettle();
  }

  Map<String, dynamic> makeItem({int qty = 1, bool selected = true}) => {
        'id': '101',
        'name': 'Optimum Nutrition Whey Protein',
        'variant': 'Standard',
        'price': 450000,
        'quantity': qty,
        'stock': 10,
        'selected': selected,
      };

  // ════════════════════════════════════════════════════════════════════════════
  //  TS.SP-4 — BVA: Boundary Value Analysis pada Quantity Cart
  // ════════════════════════════════════════════════════════════════════════════
  group('TS.SP-4 | BVA – Quantity Cart', () {
    // TC.SP-4.001 ── Min-1: qty=0 (klik (-) dari qty=1) → snackbar error ─────
    testWidgets('TC.SP-4.001 | Min-1: qty 1 → klik (-) → muncul error minimal',
        (tester) async {
      await tester.pumpWidget(buildApp(
        _MockCartPage(initialItems: [makeItem(qty: 1)]),
      ));
      await pump(tester);

      // Qty awal = 1
      expect(tester.widget<Text>(find.byKey(const Key('qty_text_0'))).data, '1');

      // Klik (-)
      await tester.tap(find.byKey(const Key('btn_minus_0')));
      await tester.pump(const Duration(milliseconds: 300));

      // Snackbar "Minimal pembelian 1 item" muncul
      expect(find.text('Minimal pembelian 1 item'), findsOneWidget);
      // Qty tetap 1
      expect(tester.widget<Text>(find.byKey(const Key('qty_text_0'))).data, '1');
    });

    // TC.SP-4.002 ── Min: qty=1 (klik (-) dari qty=2) → qty jadi 1 ──────────
    testWidgets('TC.SP-4.002 | Min: qty 2 → klik (-) → qty menjadi 1',
        (tester) async {
      await tester.pumpWidget(buildApp(
        _MockCartPage(initialItems: [makeItem(qty: 2)]),
      ));
      await pump(tester);

      await tester.tap(find.byKey(const Key('btn_minus_0')));
      await pump(tester);

      expect(tester.widget<Text>(find.byKey(const Key('qty_text_0'))).data, '1');
    });

    // TC.SP-4.003 ── Min+1: qty=2 (klik (+) dari qty=1) → qty jadi 2 ────────
    testWidgets('TC.SP-4.003 | Min+1: qty 1 → klik (+) → qty menjadi 2',
        (tester) async {
      await tester.pumpWidget(buildApp(
        _MockCartPage(initialItems: [makeItem(qty: 1)]),
      ));
      await pump(tester);

      await tester.tap(find.byKey(const Key('btn_plus_0')));
      await pump(tester);

      expect(tester.widget<Text>(find.byKey(const Key('qty_text_0'))).data, '2');
    });

    // TC.SP-4.004 ── Max-1: qty=9 (klik (+) dari qty=8) → qty jadi 9 ────────
    testWidgets('TC.SP-4.004 | Max-1: qty 8 → klik (+) → qty menjadi 9',
        (tester) async {
      await tester.pumpWidget(buildApp(
        _MockCartPage(initialItems: [makeItem(qty: 8)]),
      ));
      await pump(tester);

      await tester.tap(find.byKey(const Key('btn_plus_0')));
      await pump(tester);

      expect(tester.widget<Text>(find.byKey(const Key('qty_text_0'))).data, '9');
    });

    // TC.SP-4.005 ── Max: qty=10 (klik (+) dari qty=9) → qty jadi 10 ────────
    testWidgets('TC.SP-4.005 | Max: qty 9 → klik (+) → qty menjadi 10',
        (tester) async {
      await tester.pumpWidget(buildApp(
        _MockCartPage(initialItems: [makeItem(qty: 9)]),
      ));
      await pump(tester);

      await tester.tap(find.byKey(const Key('btn_plus_0')));
      await pump(tester);

      expect(tester.widget<Text>(find.byKey(const Key('qty_text_0'))).data, '10');
    });

    // TC.SP-4.006 ── Max+1: qty=11 (klik (+) dari qty=10) → snackbar error ──
    testWidgets(
        'TC.SP-4.006 | Max+1: qty 10 → klik (+) → muncul error stok maksimal',
        (tester) async {
      await tester.pumpWidget(buildApp(
        _MockCartPage(initialItems: [makeItem(qty: 10)], maxStock: 10),
      ));
      await pump(tester);

      await tester.tap(find.byKey(const Key('btn_plus_0')));
      await tester.pump(const Duration(milliseconds: 300));

      // Snackbar "Stok maksimal 10 item" muncul
      expect(find.text('Stok maksimal 10 item'), findsOneWidget);
      // Qty tetap 10
      expect(tester.widget<Text>(find.byKey(const Key('qty_text_0'))).data, '10');
    });
  });
}
