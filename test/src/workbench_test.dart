import 'package:cistudio/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Workbench Tests', () {
    testWidgets('Selecting a CIStep updates selectedStep',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

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
      await tester.pumpWidget(const MyApp());

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

    testWidgets(
        'Selecting a property option from the dropdown updates the selection',
        (WidgetTester tester) async {
      // Build the app and trigger a frame.
      await tester.pumpWidget(const MyApp());

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

    testWidgets(
      'Entering a value in the flutterVersion text field updates the selection',
      (WidgetTester tester) async {
        // Build the app and trigger a frame.
        await tester.pumpWidget(const MyApp());

        // Navigate to the "Setup & Cache Flutter" step settings.
        final reorderableListFinder = find.byType(ReorderableListView);
        final stepFinder = find.descendant(
          of: reorderableListFinder,
          matching: find.byKey(const ValueKey('setup-&-cache-flutter')),
        );
        await tester.tap(stepFinder);
        await tester.pumpAndSettle();

        // Find the flutterVersion text field.
        final flutterVersionFieldFinder =
            find.widgetWithText(TextField, 'Enter flutterVersion');

        // Ensure the flutterVersion text field is visible.
        await tester.ensureVisible(flutterVersionFieldFinder);
        await tester.pumpAndSettle();

        // Enter a new value in the flutterVersion text field.
        await tester.enterText(flutterVersionFieldFinder, '3.16.0');
        await tester.pump();

        // Verify that the new value is updated in the widget.
        final TextField textField = tester.widget(flutterVersionFieldFinder);
        final TextEditingController? controller = textField.controller;
        expect(controller?.text, equals('3.16.0'));
      },
    );

    testWidgets('Tapping GitHub Actions button triggers export action',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Find the GitHub Actions button by text
      final githubActionsButtonFinder =
          find.widgetWithText(ElevatedButton, 'GitHub Actions');
      expect(githubActionsButtonFinder, findsOneWidget);

      // Tap the GitHub Actions button
      await tester.tap(githubActionsButtonFinder);

      await tester.pumpAndSettle();

      // Check for a SnackBar in the ScaffoldMessenger
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.text('CI workflow file has been downloaded.'), findsOneWidget);
    });
  });
}
