import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:matrix_calc_offline/main.dart' as app;
import 'package:matrix_calc_offline/ui/tabs/matrix_ops_tab.dart' as app;
import 'package:matrix_calc_offline/ui/common/status_card.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Error display verification', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. System Solver Tab (Default)
    // Trigger error: Solve with empty input (might throw or handle gracefully, let's try 0 rows/cols if possible or just empty fields)
    // Actually empty fields default to 0.
    // Let's try Cramer's Rule with non-square matrix (default is 3x3 so it works).
    // Let's change rows to 2, cols to 3.
    
    // Find row decrement button
    await tester.tap(find.widgetWithIcon(IconButton, Icons.remove_circle_outline).first); // Rows -1 -> 2
    await tester.pumpAndSettle();
    
    // Select Cramer's Rule
    await tester.tap(find.text('Gaussian Elimination'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Cramer's Rule").last);
    await tester.pumpAndSettle();
    
    // Click Solve
    await tester.tap(find.text('Solve'));
    await tester.pumpAndSettle();
    
    // Verify Error Message in StatusCard
    expect(find.byType(StatusCard), findsOneWidget);
    expect(find.textContaining("Cramer's Rule requires a square matrix"), findsOneWidget);
    
    // Verify Dismiss
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(StatusCard), findsNothing);
    
    // 2. Matrix Ops Tab
    await tester.tap(find.text('Matrix Operations'));
    await tester.pumpAndSettle();
    
    // Trigger error: A*k without k
    // Scroll down to find the button
    final scrollable = find.descendant(
      of: find.byType(app.MatrixOpsTab),
      matching: find.byType(SingleChildScrollView),
    );
    await tester.drag(scrollable, const Offset(0, -600)); // Scroll more
    await tester.pumpAndSettle();
    
    await tester.tap(find.widgetWithText(ElevatedButton, 'A × k').first);
    await tester.pumpAndSettle();
    
    // Verify Error
    expect(find.byType(StatusCard), findsOneWidget);
    expect(find.textContaining("Enter a scalar value k"), findsOneWidget);
    
    // 3. Determinant Tab
    await tester.tap(find.text('Determinant'));
    await tester.pumpAndSettle();
    
    // Trigger error: Non-square matrix? Det tab enforces square.
    // Let's try invalid input if we could type.
    // Or maybe just empty input -> 0 -> Det is 0 (valid).
    // Let's try to find an error case.
    // Maybe just verify StatusCard is used if we can trigger one.
    // What if we enter "abc"? safeParseFraction handles it? No, safeParseFraction might throw or return 0?
    // safeParseFraction catches FormatException and rethrows if double parse fails.
    // So "abc" should throw.
    
    // Enter "abc" in first cell
    await tester.enterText(find.byType(TextField).first, "abc");
    await tester.pumpAndSettle();
    
    // Click Calculate
    await tester.tap(find.text('Calculate Determinant'));
    await tester.pumpAndSettle();
    
    // Verify Error
    expect(find.byType(StatusCard), findsOneWidget);
    expect(find.textContaining("Error"), findsOneWidget);
    
  });
}
