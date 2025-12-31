import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/ui/home_screen.dart';
import 'package:matrix_calc_offline/ui/solution_screen.dart';

void main() {
  testWidgets('HomeScreen has title and grid', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Matrix Calculator'), findsOneWidget);
    expect(find.text('Size: 3 x 3'), findsOneWidget);
    
    // Check for TextFields (3x3 matrix + 3 constants = 12 fields)
    expect(find.byType(TextField), findsNWidgets(12));
  });

  testWidgets('HomeScreen updates size', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Tap + button
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(find.text('Size: 4 x 4'), findsOneWidget);
    // 4x4 + 4 = 20 fields
    expect(find.byType(TextField), findsNWidgets(20));
  });

  testWidgets('HomeScreen solves and navigates', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Enter simple system: x = 1
    // Matrix: [[1]] (but size is 3, let's use size 2 for simplicity)
    
    // Decrease size to 2
    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pump();
    expect(find.text('Size: 2 x 2'), findsOneWidget);

    // Find all text fields
    final fields = find.byType(TextField);
    
    // Matrix:
    // 1 0
    // 0 1
    // Constants:
    // 2
    // 3
    // Solution: x=2, y=3

    // Row 0, Col 0 -> 1
    await tester.enterText(fields.at(0), '1');
    // Row 0, Col 1 -> 0 (default empty is 0)
    
    // Row 1, Col 0 -> 0
    // Row 1, Col 1 -> 1
    await tester.enterText(fields.at(3), '1'); // Index 3 is Row 1, Col 1 (0,1,2,3)

    // Constants
    // Index 4 is Const 0
    await tester.enterText(fields.at(4), '2');
    // Index 5 is Const 1
    await tester.enterText(fields.at(5), '3');

    // Tap Solve
    await tester.tap(find.text('Solve'));
    await tester.pumpAndSettle();

    // Verify navigation to SolutionScreen
    expect(find.byType(SolutionScreen), findsOneWidget);
    expect(find.text('Solution'), findsOneWidget);
    
    // Verify steps are shown
    expect(find.textContaining('Initial Augmented Matrix'), findsOneWidget);
  });
}
