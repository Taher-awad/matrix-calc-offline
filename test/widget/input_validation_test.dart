import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/main.dart';

void main() {
  testWidgets('Input Validation Test: Bad Inputs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Go to Matrix Ops Tab
    await tester.tap(find.text('Matrix Operations'));
    await tester.pumpAndSettle();

    // Find first text field of Matrix A
    var textField = find.byType(TextField).first;

    // Test 1: Enter "abc" (Invalid text)
    await tester.enterText(textField, 'abc');
    await tester.pump();
    
    // Perform operation (e.g., Det(A))
    await tester.tap(find.text('Det(A)'));
    await tester.pumpAndSettle();

    // Should show error or treat as 0. 
    // Our implementation currently catches errors and shows "Error: ..."
    expect(find.textContaining('Error'), findsOneWidget);

    // Test 2: Enter "1/0" (Division by zero)
    await tester.enterText(textField, '1/0');
    await tester.pump();
    
    await tester.tap(find.text('Det(A)'));
    await tester.pumpAndSettle();
    
    expect(find.textContaining('Error'), findsOneWidget);

    // Test 3: Enter empty string (Should be treated as 0)
    await tester.enterText(textField, '');
    await tester.pump();
    
    await tester.tap(find.text('Det(A)'));
    await tester.pumpAndSettle();
    
    // Det of zero matrix is 0
    expect(find.textContaining('0'), findsOneWidget);
    expect(find.textContaining('Error'), findsNothing);
  });
}
