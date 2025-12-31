import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/main.dart';
import 'package:matrix_calc_offline/ui/tabs/matrix_ops_tab.dart';
import 'package:matrix_calc_offline/ui/matrix_input.dart';

void main() {
  group('Comprehensive UI Tests', () {
    testWidgets('Navigation Test: Switch between all tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Default tab is System Solver
      expect(find.text('System of Equations'), findsWidgets); // Tab text and AppBar title?
      
      // Switch to Matrix Operations
      await tester.tap(find.text('Matrix Operations'));
      await tester.pumpAndSettle();
      expect(find.byType(MatrixOpsTab), findsOneWidget);

      // Switch to System Solver
      await tester.tap(find.text('System of Equations'));
      await tester.pumpAndSettle();
      expect(find.text('Solve'), findsOneWidget);

      // Switch to Determinant
      await tester.tap(find.text('Determinant'));
      await tester.pumpAndSettle();
      expect(find.text('Calculate Determinant'), findsOneWidget);

      // Switch to Eigenvalues
      await tester.tap(find.text('Eigenvalues'));
      await tester.pumpAndSettle();
      expect(find.text('Find Eigenvalues'), findsOneWidget);
    });

    testWidgets('Responsiveness Test: Phone Layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // Switch to Matrix Operations
      await tester.tap(find.text('Matrix Operations'));
      await tester.pumpAndSettle();

      // In phone layout, Matrix A and B should be in a Column (vertical)
      final matrixAFinder = find.text('Matrix A');
      final matrixBFinder = find.text('Matrix B');
      
      final matrixAPos = tester.getCenter(matrixAFinder);
      final matrixBPos = tester.getCenter(matrixBFinder);

      // A should be above B (smaller Y)
      expect(matrixAPos.dy, lessThan(matrixBPos.dy));
      // X coordinates should be roughly similar (centered)
      expect((matrixAPos.dx - matrixBPos.dx).abs(), lessThan(50));
    });

    testWidgets('Responsiveness Test: Desktop Layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // Switch to Matrix Operations
      await tester.tap(find.text('Matrix Operations'));
      await tester.pumpAndSettle();

      final matrixAFinder = find.text('Matrix A');
      final matrixBFinder = find.text('Matrix B');

      final matrixAPosDesktop = tester.getCenter(matrixAFinder);
      final matrixBPosDesktop = tester.getCenter(matrixBFinder);

      // A should be to the left of B (smaller X)
      expect(matrixAPosDesktop.dx, lessThan(matrixBPosDesktop.dx));
      // Y coordinates should be roughly similar
      expect((matrixAPosDesktop.dy - matrixBPosDesktop.dy).abs(), lessThan(50));
    });

    testWidgets('Dynamic Resizing Test', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // Switch to Matrix Operations
      await tester.tap(find.text('Matrix Operations'));
      await tester.pumpAndSettle();

      debugPrint("Found MatrixOpsTab: ${find.byType(MatrixOpsTab).evaluate().length}");
      debugPrint("Found MatrixInput: ${find.byType(MatrixInput).evaluate().length}");

      // Find Matrix A Input widget
      final matrixAFinder = find.byType(MatrixInput).first;
      
      // Helper to count fields in Matrix A
      int countFieldsInA() {
        return find.descendant(
          of: matrixAFinder,
          matching: find.byType(TextField),
        ).evaluate().length;
      }

      // Initial: 3x3 = 9
      expect(countFieldsInA(), equals(9));

      // Find Add buttons INSIDE Matrix A
      final addButtonsA = find.descendant(
        of: matrixAFinder,
        matching: find.byIcon(Icons.add),
      );
      
      // Index 0: Rows +, Index 1: Cols +
      await tester.tap(addButtonsA.at(0)); 
      await tester.pumpAndSettle();
      
      // Now Rows should be 4. Cols 3. Total 12 fields for A.
      expect(countFieldsInA(), equals(12));
      
      await tester.tap(addButtonsA.at(1)); 
      await tester.pumpAndSettle();
      
      // Now 4x4. Total 16 fields for A.
      expect(countFieldsInA(), equals(16));
      
      // Find Remove buttons INSIDE Matrix A
      final removeButtonsA = find.descendant(
        of: matrixAFinder,
        matching: find.byIcon(Icons.remove),
      );
      
      // Reduce to 2x2
      // Tap "-" for Rows (first remove icon) twice
      await tester.tap(removeButtonsA.at(0));
      await tester.pumpAndSettle();
      await tester.tap(removeButtonsA.at(0));
      await tester.pumpAndSettle();
      
      // Tap "-" for Cols (second remove icon) twice
      await tester.tap(removeButtonsA.at(1));
      await tester.pumpAndSettle();
      await tester.tap(removeButtonsA.at(1));
      await tester.pumpAndSettle();
      
      // Now 2x2. Total 4 fields for A.
      expect(countFieldsInA(), equals(4));
    });
  });
}
