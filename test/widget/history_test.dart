import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/ui/home_screen.dart';
import 'package:matrix_calc_offline/logic/history_service.dart';

void main() {
  setUp(() {
    HistoryService().clear();
  });

  testWidgets('History Feature Integration Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    // 1. Go to Matrix Ops Tab (Index 1)
    await tester.tap(find.text('Matrix Operations'));
    await tester.pumpAndSettle();

    // 2. Enter Matrix A: [1 2; 3 4]
    // Matrix Ops has 2 MatrixInputs. First is A.
    // Fields 0-8.
    await tester.enterText(find.byType(TextField).at(0), '1');
    await tester.enterText(find.byType(TextField).at(1), '2');
    await tester.enterText(find.byType(TextField).at(3), '3');
    await tester.enterText(find.byType(TextField).at(4), '4');

    // 3. Enter Matrix B: [1 0; 0 1]
    // Fields 9-17.
    await tester.enterText(find.byType(TextField).at(9), '1');
    await tester.enterText(find.byType(TextField).at(10), '0');
    await tester.enterText(find.byType(TextField).at(12), '0');
    await tester.enterText(find.byType(TextField).at(13), '1');

    // 4. Perform A + B
    final addBtn = find.text('+');
    expect(addBtn, findsOneWidget, reason: "Add button not found");
    await tester.ensureVisible(addBtn);
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // 5. Verify Solution Screen
    if (find.textContaining('Result').evaluate().isEmpty) {
      debugDumpApp();
      // Check for error message
      expect(find.textContaining('Error'), findsNothing, reason: "Calculation failed with error");
    }
    expect(find.textContaining('Result'), findsAtLeastNWidgets(1));
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 6. Go to History Tab (Index 4)
    final historyTab = find.text('History');
    await tester.ensureVisible(historyTab);
    await tester.tap(historyTab);
    await tester.pumpAndSettle();

    // 7. Verify History Item
    expect(find.textContaining('A+B'), findsAtLeastNWidgets(1));
    // Result [2 2; 3 5]
    expect(find.text('2'), findsAtLeastNWidgets(1));
    expect(find.text('5'), findsAtLeastNWidgets(1));
    // Result [2 2; 3 5]
    expect(find.text('2'), findsAtLeastNWidgets(1));
    expect(find.text('5'), findsAtLeastNWidgets(1));

    // 8. Click "To Det"
    await tester.tap(find.text('To Det'));
    await tester.pumpAndSettle();

    // 9. Verify switch to Determinant Tab
    // Determinant Tab should be active.
    // And Matrix A in Determinant Tab should be populated with [2 2; 3 5].
    // Determinant Tab has "Calculate Determinant" button.
    expect(find.text('Calculate Determinant'), findsOneWidget);
    
    // Check values in text fields.
    // Determinant Tab has 1 MatrixInput (fields 0-8).
    // Index 0 should be '2'.
    expect(find.widgetWithText(TextField, '2'), findsAtLeastNWidgets(1));
    expect(find.widgetWithText(TextField, '5'), findsAtLeastNWidgets(1));
  });
}
