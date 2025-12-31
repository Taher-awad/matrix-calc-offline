import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/ui/home_screen.dart';
import 'package:matrix_calc_offline/logic/history_service.dart';
import 'package:matrix_calc_offline/logic/matrix.dart';
import 'package:fraction/fraction.dart';

void main() {
  setUp(() {
    HistoryService().clear();
  });

  testWidgets('History Resize Integration Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    // 1. Add a 3x2 matrix to history manually
    Matrix m3x2 = Matrix(3, 2);
    m3x2.set(0, 0, Fraction(1)); m3x2.set(0, 1, Fraction(2));
    m3x2.set(1, 0, Fraction(3)); m3x2.set(1, 1, Fraction(4));
    m3x2.set(2, 0, Fraction(5)); m3x2.set(2, 1, Fraction(6));
    HistoryService().add(m3x2, "Test 3x2");

    // 2. Go to History Tab
    final historyTab = find.text('History');
    await tester.ensureVisible(historyTab);
    await tester.tap(historyTab);
    await tester.pumpAndSettle();

    // 3. Verify item exists
    expect(find.text('Test 3x2'), findsOneWidget);

    // 4. Click "To Ops A"
    await tester.tap(find.text('To Ops A'));
    await tester.pumpAndSettle();

    // 5. Verify switch to Matrix Ops Tab
    // Matrix Ops Tab should be active.
    // Matrix A should be 3x2.
    // Check for "3" and "2" in size selector.
    // MatrixInput has Row with Text('$rows') ... Text('$cols').
    // We need to find the specific MatrixInput for A.
    // It's the first one.
    
    // Let's check the text fields count. Should be 6.
    // Matrix A fields are 0-5.
    // Matrix B fields are 6-14 (default 3x3).
    
    // Verify field 0 has '1'.
    if (find.widgetWithText(TextField, '1').evaluate().isEmpty) {
      debugDumpApp();
    }
    expect(find.widgetWithText(TextField, '1'), findsAtLeastNWidgets(1));
    
    // Verify field 5 (row 2, col 1) has '6'.
    expect(find.widgetWithText(TextField, '6'), findsAtLeastNWidgets(1));

    // Verify field 6 (start of B) is empty (or default).
    
    // Verify size text.
    // We can find Text('3') and Text('2') in the size selector row.
    // But there might be multiple '3's.
    // Let's just verify that the input grid has 6 items.
    // MatrixInput uses GridView.
    // We can find GridView and check itemCount?
    // Or just check that we don't have 9 fields for A.
    
    // If resizing failed, it would still be 3x3 (9 fields).
    // If resizing succeeded, it should be 3x2 (6 fields).
    // But Matrix B is 3x3 (9 fields).
    // Total fields = 15.
    // If A was 3x3, total = 9 + 9 + 1 = 19.
    
    expect(find.byType(TextField), findsNWidgets(16));
  });
}
