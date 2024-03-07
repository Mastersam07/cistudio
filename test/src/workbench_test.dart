import 'package:cistudio/src/workbench.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Workbench Tests', () {
    testWidgets('Selecting a CIStep updates selectedStep',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MaterialApp(home: Workbench()));

      final setupCacheFlutterKey =
          find.byKey(const ValueKey("setup-&-cache-flutter"));
      expect(setupCacheFlutterKey, findsOneWidget);

      // Tap on the step
      await tester.tap(setupCacheFlutterKey);
      await tester.pump(); // Wait for any animations to complete

      expect(find.text('Editing Step: Setup & Cache Flutter'), findsOneWidget);
      expect(find.text('cache'), findsOneWidget);
      expect(find.byType(DropdownButton), findsWidgets);
    });

    testWidgets(
        'Reordering a CIStep in the ReorderableListView updates the order',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Workbench()));

      // Ensure the reorderable list is populated.
      await tester.pumpAndSettle();

      // Find the first and second items in the reorderable list.
      final reorderableListFinder = find.byType(ReorderableListView);
      final firstItemFinder = find.descendant(
        of: reorderableListFinder,
        matching: find.byKey(const ValueKey('checkout-repo')),
      );
      final secondItemFinder = find.descendant(
        of: reorderableListFinder,
        matching: find.byKey(const ValueKey('setup-&-cache-flutter')),
      );

      final Offset targetItemOffset = tester.getCenter(secondItemFinder);
      await tester.drag(
          firstItemFinder, Offset(0, targetItemOffset.dy * 1.5)); // Drag down
      await tester.pumpAndSettle(); // Settle the animations and UI updates

      final List<String> actualOrder = tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) => widget.data!)
          .toList();

      // Define the expected order of items after reordering
      final List<String> expectedOrder = [
        'Setup & Cache Flutter', // This should now be the first item after reordering
        'Checkout Repo', // This item was moved
      ];

      expect(actualOrder, containsAllInOrder(expectedOrder));
    });
  });

  testWidgets(
      'Selecting a property option from the dropdown updates the selection',
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: Workbench()));

    final reorderableListFinder = find.byType(ReorderableListView);
    final stepFinder = find.descendant(
      of: reorderableListFinder,
      matching: find.byKey(const ValueKey('setup-&-cache-flutter')),
    );
    await tester.tap(stepFinder);
    await tester.pumpAndSettle();

    final cacheDropdownFinder = find.byKey(const ValueKey('dropdown-cache'));
    await tester.ensureVisible(cacheDropdownFinder);
    await tester.pumpAndSettle();
    await tester.tap(cacheDropdownFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('without').last);
    await tester.pumpAndSettle();

    final DropdownButton<dynamic> dropdownButton =
        tester.widget(cacheDropdownFinder);
    expect(dropdownButton.value, equals('without'));
  });
}
