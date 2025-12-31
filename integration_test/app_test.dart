import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:matrix_calc_offline/main.dart' as app;
import 'package:matrix_calc_offline/ui/solution_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('solve system, calculate eigenvalues, and perform matrix ops',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. System Solver Tab
      await tester.tap(find.text('System of Equations'));
      await tester.pumpAndSettle();
      
      // Enter values for 2x2 system:
      // 1x + 1y = 3
      // 1x - 1y = 1
      // Solution: x=2, y=1
      
      // Resize to 2x2
      await tester.tap(find.byIcon(Icons.remove_circle_outline).first); // Decrease size
      await tester.pumpAndSettle();
      
      // Find text fields. There are 2x2=4 for matrix + 2 for constants = 6 fields.
      // We need to be careful with finding them.
      // The MatrixInput widget creates TextFields.
      // Let's assume standard order (row by row).
      
      var textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(6)); // 4 for matrix, 2 for constants
      
      // Matrix A
      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '1');
      await tester.enterText(textFields.at(2), '1');
      await tester.enterText(textFields.at(3), '-1');
      
      // Constants
      await tester.enterText(textFields.at(4), '3');
      await tester.enterText(textFields.at(5), '1');
      
      // Select Cramer's Rule
      await tester.tap(find.text('Gaussian Elimination'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Cramer's Rule").last);
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Solve'));
      await tester.pumpAndSettle();
      
      expect(find.byType(SolutionScreen), findsOneWidget);
      // Cramer's rule output format: "x_1 = ... = 2"
      expect(find.textContaining('x_1'), findsOneWidget);
      expect(find.textContaining('2'), findsWidgets); // 2 is the value for x1
      expect(find.textContaining('1'), findsWidgets); // 1 is the value for x2
      
      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      // 2. Eigenvalues Tab
      await tester.tap(find.text('Eigenvalues'));
      await tester.pumpAndSettle();
      
      // Resize to 2x2
      await tester.tap(find.byIcon(Icons.remove).first); // Decrease rows
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.remove).last); // Decrease cols
      await tester.pumpAndSettle();
      
      // Enter Identity Matrix
      // 1 0
      // 0 1
      var eigenFields = find.byType(TextField);
      await tester.enterText(eigenFields.at(0), '1');
      await tester.enterText(eigenFields.at(1), '0');
      await tester.enterText(eigenFields.at(2), '0');
      await tester.enterText(eigenFields.at(3), '1');
      
      await tester.tap(find.text('Find Eigenvalues'));
      await tester.pumpAndSettle();
      
      expect(find.textContaining('Eigenvalue: 1.0000'), findsOneWidget);
      
      // Test Symbolic Input
      // Enter [[x, 1], [0, x]]
      // Eigenvalues should be x, x
      // Clear fields first? Or just overwrite.
      await tester.enterText(eigenFields.at(0), 'x');
      await tester.enterText(eigenFields.at(1), '1');
      await tester.enterText(eigenFields.at(2), '0');
      await tester.enterText(eigenFields.at(3), 'x');
      
      await tester.tap(find.text('Find Eigenvalues'));
      await tester.pumpAndSettle();
      
      // Should show "Symbolic Solution"
      expect(find.textContaining('Symbolic Solution'), findsOneWidget);
      // Should show characteristic polynomial containing x
      // (x - L)(x - L) = x^2 - 2xL + L^2
      // The output format depends on implementation.
      // Let's just check it didn't crash and showed the header.
      expect(find.textContaining('Characteristic Polynomial'), findsOneWidget);
      
      // 3. Matrix Ops Tab
      await tester.tap(find.text('Matrix Operations'));
      await tester.pumpAndSettle();
      
      // Just test A + B with default 3x3 zero matrices
      await tester.tap(find.text('A + B'));
      await tester.pumpAndSettle();
      
      expect(find.textContaining('Result (A+B)'), findsOneWidget);
      
      // Calculate Determinant of A
      await tester.tap(find.text('Det(A)'));
      await tester.pumpAndSettle();
      // Det(0) = 0
      expect(find.textContaining('0'), findsOneWidget);
      
      // Calculate Inverse of A (Singular -> Error)
      await tester.tap(find.text('Inv(A)'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Error'), findsOneWidget);
      
      // Change A to Identity to test Inverse success
      // A is 3x3.
      // Need to clear and set 1s on diagonal.
      // This is tedious with finding specific TextFields by index.
      // Let's just resize to 1x1 for simplicity? No, min size is usually 2 or 1.
      // Let's resize to 2x2.
      await tester.tap(find.byIcon(Icons.remove).at(0)); // Decrease Rows A
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.remove).at(1)); // Decrease Cols A
      await tester.pumpAndSettle();
      
      // Now 2x2. TextFields indices changed.
      // A fields are first 4.
      var opsFields = find.byType(TextField);
      await tester.enterText(opsFields.at(0), '1');
      await tester.enterText(opsFields.at(1), '0');
      await tester.enterText(opsFields.at(2), '0');
      await tester.enterText(opsFields.at(3), '1');
      
      await tester.tap(find.text('Inv(A)'));
      await tester.pumpAndSettle();
      
      // Inv(I) = I
      expect(find.textContaining('1'), findsWidgets);
      expect(find.textContaining('0'), findsWidgets);
      
      // Test Swap
      // A is Identity (1,0,0,1). B is Zero (default).
      // Swap -> A should be Zero, B should be Identity.
      // In mobile layout (default for test?), swap icon might be swap_vert or swap_horiz depending on size.
      // Integration tests run on device size. Usually 800x600 or similar.
      // Let's look for either icon.
      var swapBtn = find.byIcon(Icons.swap_horiz);
      if (swapBtn.evaluate().isEmpty) {
        swapBtn = find.byIcon(Icons.swap_vert);
      }
      await tester.tap(swapBtn);
      await tester.pumpAndSettle();
      
      // Check A is all zeros (first 4 fields)
      // Actually checking text fields content is robust.
      expect(find.descendant(of: opsFields.at(0), matching: find.text('0')), findsOneWidget);
      
      // 4. System Solver - New Methods
      await tester.tap(find.text('System Solver'));
      await tester.pumpAndSettle();
      
      // Select Gauss-Jordan
      await tester.tap(find.text('Gaussian Elimination')); // Open dropdown
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gauss-Jordan Elimination').last);
      await tester.pumpAndSettle();
      
      // Enter 2x2 system
      // 1x + 1y = 2
      // 1x - 1y = 0
      // Solution: x=1, y=1
      var sysFields = find.byType(TextField);
      // Matrix A (2x2 = 4 fields) + Constants (2 fields) = 6 fields
      await tester.enterText(sysFields.at(0), '1');
      await tester.enterText(sysFields.at(1), '1');
      await tester.enterText(sysFields.at(2), '1');
      await tester.enterText(sysFields.at(3), '-1');
      await tester.enterText(sysFields.at(4), '2');
      await tester.enterText(sysFields.at(5), '0');
      
      await tester.tap(find.text('Solve'));
      await tester.pumpAndSettle();
      
      expect(find.textContaining('Reduced Row Echelon Form'), findsOneWidget);
      
      // 5. Eigenvalues - Diagonalization
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eigenvalues'));
      await tester.pumpAndSettle();
      
      // Enter diagonal matrix [2 0; 0 3]
      await tester.enterText(eigenFields.at(0), '2');
      await tester.enterText(eigenFields.at(1), '0');
      await tester.enterText(eigenFields.at(2), '0');
      await tester.enterText(eigenFields.at(3), '3');
      
      await tester.tap(find.text('Diagonalize Matrix'));
      await tester.pumpAndSettle();
      
      expect(find.textContaining('Matrix D'), findsOneWidget);
      expect(find.textContaining('Matrix P'), findsOneWidget);
    });
  });
}
