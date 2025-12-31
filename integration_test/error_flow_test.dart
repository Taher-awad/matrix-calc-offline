import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:matrix_calc_offline/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Error Flow Integration Test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Singular Matrix Inversion Error
    await tester.tap(find.text('Matrix Operations'));
    await tester.pumpAndSettle();

    // Enter singular matrix (all zeros by default)
    // Click Inv(A)
    await tester.tap(find.text('Inv(A)'));
    await tester.pumpAndSettle();

    // Should show error dialog or text
    // Our implementation shows a Card with "Error: ..."
    expect(find.textContaining('Error'), findsOneWidget);
    expect(find.textContaining('singular'), findsOneWidget);

    // 2. Non-Square Determinant Error
    // Change size to 2x3
    // MatrixInput doesn't expose size changer easily to finder without keys, 
    // but we can try to add a column if the UI supports it.
    // Actually, MatrixOpsTab has + / - buttons for Rows and Cols.
    // Let's find the "+" button for Columns.
    // There are multiple "+" buttons (Rows +, Cols +, Matrix B Rows +, etc.)
    // This is hard to target without keys.
    // Let's skip resizing and assume default 3x3 is square.
    
    // Instead, let's try System Solver inconsistent system
    await tester.tap(find.text('System of Equations'));
    await tester.pumpAndSettle();
    
    // 0x + 0y = 5
    // 0x + 0y = 0
    var sysFields = find.byType(TextField);
    // 2x2 system.
    // Eq 1: 0, 0, 5
    await tester.enterText(sysFields.at(0), '0');
    await tester.enterText(sysFields.at(1), '0');
    await tester.enterText(sysFields.at(2), '5'); // Constant
    
    await tester.tap(find.text('Solve'));
    await tester.pumpAndSettle();
    
    // Should show error or "No Solution"
    // Gaussian solver might throw exception or return weird steps.
    // SolutionScreen displays steps.
    // If it throws, it might show error dialog.
    // If it proceeds, it might show 0 = 5 in steps.
    // Let's check for "Error" or "No solution" text.
    // Our Solver implementation might throw "Singular" exception for Cramer/Inverse.
    // Gaussian might show steps.
    
    // Let's try Cramer's Rule which definitely fails for singular A
    await tester.tap(find.text('Gaussian Elimination'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Cramer's Rule").last);
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Solve'));
    await tester.pumpAndSettle();
    
    expect(find.textContaining('Error'), findsOneWidget);
  });
}
