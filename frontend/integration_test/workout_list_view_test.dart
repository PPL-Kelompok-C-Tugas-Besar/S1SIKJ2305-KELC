import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro/screens/catalogue/catalogue_page.dart';
import 'package:gymbro/utils/palette.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp() {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: kBg,
        body: CataloguePage(),
      ),
    );
  }

  Future<void> waitForCatalogueLoad(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }

  int visibleWorkoutCount(WidgetTester tester) {
    final countFinder = find.textContaining(RegExp(r'^\d+ found$'));
    expect(countFinder, findsOneWidget);

    final countText = tester.widget<Text>(countFinder).data ?? '';
    return int.parse(countText.split(' ').first);
  }

  Future<void> scrollWorkoutListToBottom(WidgetTester tester) async {
    final scrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    expect(scrollable, findsOneWidget);

    final state = tester.state<ScrollableState>(scrollable);

    for (var i = 0; i < 20 && state.position.extentAfter > 0; i++) {
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
    }

    expect(state.position.extentAfter, 0);
  }

  group('Workout Catalogue - View Workout List', () {
    testWidgets('user can see the list of workouts', (tester) async {
      await tester.pumpWidget(buildApp());
      await waitForCatalogueLoad(tester);

      expect(find.text('Train'), findsOneWidget);
      expect(find.text('What do you want to focus on today?'), findsOneWidget);
      expect(find.text('Workouts'), findsOneWidget);
      expect(find.textContaining('found'), findsOneWidget);
      expect(visibleWorkoutCount(tester), greaterThan(0));
      expect(find.byIcon(Icons.arrow_forward_rounded), findsAtLeastNWidgets(1));

      await scrollWorkoutListToBottom(tester);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsAtLeastNWidgets(1));
    });
  });
}
