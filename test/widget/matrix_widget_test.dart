import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/logic/matrix.dart';
import 'package:matrix_calc_offline/ui/matrix_widget.dart';
import 'package:fraction/fraction.dart';

void main() {
  testWidgets('MatrixWidget renders correctly', (WidgetTester tester) async {
    Matrix m = Matrix(2, 2);
    m.set(0, 0, Fraction(1));
    m.set(0, 1, Fraction(2));
    m.set(1, 0, Fraction(3));
    m.set(1, 1, Fraction(4));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MatrixWidget(matrix: m),
      ),
    ));

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    
    // Verify custom painter is used
    expect(find.byType(CustomPaint), findsOneWidget);
  });
}
