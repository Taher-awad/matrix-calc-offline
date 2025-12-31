import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/main.dart';

void main() {
  testWidgets('Layout Test: Responsive Matrix Input', (WidgetTester tester) async {
    // 1. Large Screen (Desktop/Tablet) -> Row Layout
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Matrix Operations'));
    await tester.pumpAndSettle();

    // In Row layout, Matrix A and B are side-by-side.
    // We can check if they are in a Row.
    // Finding the specific Row is tricky, but we can check relative positions.
    
    final matrixAFinder = find.text('Matrix A');
    final matrixBFinder = find.text('Matrix B');
    
    final matrixAPos = tester.getCenter(matrixAFinder);
    final matrixBPos = tester.getCenter(matrixBFinder);
    
    // In Row layout, Y should be roughly same, X should be different
    expect((matrixAPos.dy - matrixBPos.dy).abs(), lessThan(50));
    expect(matrixAPos.dx, lessThan(matrixBPos.dx));

    // 2. Small Screen (Phone) -> Column Layout
    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    
    // Re-find positions
    final matrixAPosSmall = tester.getCenter(matrixAFinder);
    final matrixBPosSmall = tester.getCenter(matrixBFinder);
    
    // In Column layout, X should be roughly same (centered), Y should be different
    expect((matrixAPosSmall.dx - matrixBPosSmall.dx).abs(), lessThan(50));
    expect(matrixAPosSmall.dy, lessThan(matrixBPosSmall.dy));
    
    // 3. Verify Swap Button and New Ops Layout
    // Reset to large screen
    tester.view.physicalSize = const Size(1200, 800);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Matrix Operations'));
    await tester.pumpAndSettle();
    
    // Swap button (icon swap_horiz for row layout)
    expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    
    // Ops buttons (+, -, x) should be present
    expect(find.text('+'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
    expect(find.text('×'), findsOneWidget);
    
    // Verify Swap Functionality
    // Enter '1' in A[0][0] and '2' in B[0][0]
    var textFields = find.byType(TextField);
    // A is first matrix, B is second.
    // A has rows*cols fields. Default 3x3=9.
    // A[0][0] is index 0. B[0][0] is index 9.
    await tester.enterText(textFields.at(0), '1');
    await tester.enterText(textFields.at(9), '2');
    
    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pump();
    
    // A[0][0] should now be '2', B[0][0] should be '1'
    expect(find.descendant(of: textFields.at(0), matching: find.text('2')), findsOneWidget);
    expect(find.descendant(of: textFields.at(9), matching: find.text('1')), findsOneWidget);
  });
}
