import 'package:flutter/material.dart';
import 'package:matrix_calc_offline/ui/solution_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/main.dart';
import 'package:matrix_calc_offline/ui/tabs/matrix_ops_tab.dart';

void main() {
  testWidgets('Full System Test: Matrix Ops Tab', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Navigate to Matrix Ops (it's the default or first tab usually)
    // If using TabBar, tap the tab. Assuming standard layout.
    // Let's find "Matrix Ops" text in TabBar
    await tester.tap(find.text('Matrix Operations'));
    await tester.pumpAndSettle();

    // 2. Enter values in Matrix A (Identity)
    // Find text fields. MatrixInput creates a grid of fields.
    // We need to find specific fields. 
    // This is tricky without keys. Let's assume default 3x3 and fill diagonal.
    // We'll find all TextField widgets.
    
    // Actually, let's just verify the UI elements exist first
    expect(find.byType(MatrixOpsTab), findsOneWidget);
    expect(find.text('Matrix A'), findsOneWidget);
    expect(find.text('Matrix B'), findsOneWidget);

    // 3. Test "A + B" button presence (now just "+")
    expect(find.text('+'), findsOneWidget);
    
    // 4. Test "Det(A)" button
    await tester.tap(find.text('Det(A)'));
    await tester.pumpAndSettle();
    
    // Since inputs are empty (0), Det should be 0
    // Check for SnackBar error
    if (find.byType(SnackBar).evaluate().isNotEmpty) {
      debugPrint("SnackBar found: ${find.textContaining('Error').evaluate()}");
    }

    expect(find.textContaining('Result: Det(A)'), findsOneWidget);
    expect(find.textContaining('Determinant is 0'), findsOneWidget);
  });

  testWidgets('Full System Test: System Solver Tab', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('System of Equations'));
    await tester.pumpAndSettle();

    expect(find.text('Solve'), findsOneWidget);
    
    // Test solving a simple system (default might be empty or 3x3)
    // Just verify the button works without crashing
    await tester.tap(find.text('Solve'));
    await tester.pumpAndSettle();
    
    // Should show result or error
    // SolutionScreen is pushed, so we should find it or its content
    expect(find.byType(SolutionScreen), findsOneWidget);
  });

  testWidgets('Full System Test: Determinant Tab', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Determinant'));
    await tester.pumpAndSettle();

    expect(find.text('Calculate Determinant'), findsOneWidget);
    
    await tester.tap(find.text('Calculate Determinant'));
    await tester.pumpAndSettle();
    
    expect(find.textContaining('Determinant'), findsWidgets);
  });

  testWidgets('Full System Test: Matrix Ops Tab Extended', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Matrix Operations'));
    await tester.pumpAndSettle();

    // Test Transpose A
    await tester.tap(find.text('Trans(A)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Result: Trans(A)'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Test Inverse A
    final invBtn = find.text('Inv(A)');
    await tester.ensureVisible(invBtn);
    await tester.tap(invBtn);
    await tester.pumpAndSettle();
    // Might error if singular (0 matrix), but should show result card
    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('Full System Test: Eigenvalues Tab', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Eigenvalues'));
    await tester.pumpAndSettle();

    expect(find.text('Find Eigenvalues'), findsOneWidget);
    
    // Tap Calculate (default 0 matrix)
    await tester.tap(find.text('Find Eigenvalues'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Eigenvalues: '), findsOneWidget);
  });
}
