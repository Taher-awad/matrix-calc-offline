import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:matrix_calc_offline/main.dart' as app;
import 'package:matrix_calc_offline/ui/tabs/matrix_ops_tab.dart' as app;
import 'package:matrix_calc_offline/ui/matrix_input.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Matrix Power A^n verification', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Navigate to Matrix Ops Tab
    await tester.tap(find.text('Matrix Operations'));
    await tester.pumpAndSettle();
    
    // 2. Enter Matrix A (Identity 2x2 for simplicity, or something simple)
    // Default is 3x3. Let's resize to 2x2.
    final removeRow = find.descendant(
      of: find.widgetWithText(MatrixInput, "Matrix A"),
      matching: find.widgetWithIcon(IconButton, Icons.remove),
    ).at(0); // First remove is for rows
    await tester.tap(removeRow); // 2 rows
    await tester.pumpAndSettle();
    
    final removeCol = find.descendant(
      of: find.widgetWithText(MatrixInput, "Matrix A"),
      matching: find.widgetWithIcon(IconButton, Icons.remove),
    ).at(1); // Second remove is for cols (after rebuild it might be at index 1 again)
    // Wait, after tap, widget rebuilds.
    // We should find it again.
    
    final removeCol2 = find.descendant(
      of: find.widgetWithText(MatrixInput, "Matrix A"),
      matching: find.widgetWithIcon(IconButton, Icons.remove),
    ).at(1);
    await tester.tap(removeCol2); // 2 cols
    await tester.pumpAndSettle();
    
    // Enter values: [[2, 0], [0, 2]]
    final inputs = find.descendant(
      of: find.widgetWithText(MatrixInput, "Matrix A"),
      matching: find.byType(TextField),
    );
    await tester.enterText(inputs.at(0), "2");
    await tester.enterText(inputs.at(3), "2"); // 2x2: 0,1,2,3 indices? No, row major.
    // 0: (0,0), 1: (0,1), 2: (1,0), 3: (1,1)
    await tester.pumpAndSettle();
    
    // 3. Enter Power n = 2
    await tester.enterText(find.widgetWithText(TextField, "Scalar k / Power n"), "2");
    await tester.pumpAndSettle();
    
    // 4. Click A^n
    // Scroll to button first
    final scrollable = find.descendant(
      of: find.byType(app.MatrixOpsTab),
      matching: find.byType(SingleChildScrollView),
    );
    await tester.drag(scrollable, const Offset(0, -600));
    await tester.pumpAndSettle();
    
    await tester.tap(find.widgetWithText(ElevatedButton, 'A ^ n'));
    await tester.pumpAndSettle();
    
    // 5. Verify Result Screen
    expect(find.text('Result: A^n'), findsOneWidget);
    // Result should be [[4, 0], [0, 4]]
    expect(find.text('4'), findsAtLeastNWidgets(2));
  });
}
