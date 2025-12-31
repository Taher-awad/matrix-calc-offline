import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/main.dart';

void main() {
  testWidgets('Determinant UI: Expansion Options', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Determinant'));
    await tester.pumpAndSettle();

    // Default: Gaussian Elimination. "Row Index" dropdown should NOT be visible.
    expect(find.text('Row Index: '), findsNothing);
    expect(find.text('Column Index: '), findsNothing);

    // Select "Expand along Row"
    await tester.tap(find.text('Gaussian Elimination'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expand along Row').last);
    await tester.pumpAndSettle();

    // Now "Row Index: " should be visible
    expect(find.text('Row Index: '), findsOneWidget);
    
    // Select "Expand along Column"
    await tester.tap(find.text('Expand along Row'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expand along Column').last);
    await tester.pumpAndSettle();

    // Now "Column Index: " should be visible
    expect(find.text('Column Index: '), findsOneWidget);
    
    // Select "Montante's Method"
    await tester.tap(find.text('Expand along Column'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Montante's Method").last);
    await tester.pumpAndSettle();
    
    // Should disappear
    expect(find.text('Row Index: '), findsNothing);
    expect(find.text('Column Index: '), findsNothing);
  });
}
