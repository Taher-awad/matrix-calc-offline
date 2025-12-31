import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/logic/matrix.dart';
// For MatrixEvent
import 'package:matrix_calc_offline/ui/tabs/matrix_ops_tab.dart';
import 'package:fraction/fraction.dart';
import 'package:matrix_calc_offline/ui/home_screen.dart'; // For MatrixEvent definition

void main() {
  testWidgets('History Transfer Formats Complex Fractions as Decimals', (WidgetTester tester) async {
    // Create a matrix with a complex fraction
    // 44098 / 193727 approx 0.227629
    Matrix m = Matrix(1, 1);
    m.set(0, 0, Fraction(44098, 193727));

    // Create MatrixEvent
    MatrixEvent event = MatrixEvent(m);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MatrixOpsTab(matrixAEvent: event),
      ),
    ));
    await tester.pumpAndSettle();

    // Verify the text field content
    // Current behavior: "44098/193727"
    // Desired behavior: "0.2276" (approx)
    
    // We expect it to match decimal format for large denominators
    expect(find.textContaining('0.2276'), findsOneWidget);
    
    // It should NOT show the raw fraction
    expect(find.textContaining('44098/193727'), findsNothing);
  });
}
