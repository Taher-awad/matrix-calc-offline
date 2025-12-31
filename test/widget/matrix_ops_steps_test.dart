import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/ui/tabs/matrix_ops_tab.dart';
import 'package:matrix_calc_offline/ui/solution_screen.dart';

void main() {
  testWidgets('MatrixOpsTab navigates to SolutionScreen with steps', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MatrixOpsTab())));
    await tester.pumpAndSettle();

    // Enter Matrix A: [1 2; 3 4]
    // Matrix A is the first MatrixInput.
    // We need to find the text fields.
    // MatrixInput has 9 fields (3x3 default).
    // Matrix A fields are 0-8.
    
    await tester.enterText(find.byType(TextField).at(0), '1');
    await tester.enterText(find.byType(TextField).at(1), '2');
    await tester.enterText(find.byType(TextField).at(3), '3');
    await tester.enterText(find.byType(TextField).at(4), '4');

    // Enter Matrix B: [1 0; 0 1]
    // Matrix B fields are 9-17.
    await tester.enterText(find.byType(TextField).at(9), '1');
    await tester.enterText(find.byType(TextField).at(10), '0');
    await tester.enterText(find.byType(TextField).at(12), '0');
    await tester.enterText(find.byType(TextField).at(13), '1');

    // Tap A + B
    await tester.tap(find.text('+')); // The button text is '+'
    await tester.pumpAndSettle();

    // Verify navigation to SolutionScreen
    expect(find.byType(SolutionScreen), findsOneWidget);
    expect(find.text('Result: A+B'), findsOneWidget);
    
    // Verify steps are shown
    // "Result = A + B (Element-wise addition)"
    expect(find.textContaining('Element-wise addition'), findsOneWidget);
    
    // Verify result matrix [2 2; 3 5]
    // MatrixWidget displays elements.
    expect(find.text('2'), findsAtLeastNWidgets(2));
    expect(find.text('3'), findsAtLeastNWidgets(1));
    expect(find.text('5'), findsAtLeastNWidgets(1));
  });
}
