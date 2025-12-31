import 'package:flutter_test/flutter_test.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:matrix_calc_offline/logic/symbolic_matrix.dart';

void main() {
  group('SymbolicMatrix', () {
    test('Creation from strings', () {
      var m = SymbolicMatrix.fromStrings([
        ['1', '2x'],
        ['y', '3']
      ]);
      expect(m.get(0, 0).toString(), '1.0');
      expect(m.get(0, 1).toString(), '(2.0 * x)');
    });

    test('Symbolic Determinant (2x2)', () {
      // [[1, x], [x, 1]] -> 1 - x^2
      var m = SymbolicMatrix.fromStrings([
        ['1', 'x'],
        ['x', '1']
      ]);
      Expression det = m.determinant();
      // Actual: '((1.0 * 1.0) - (x * x))'
      expect(det.toString(), contains('x * x'));
      expect(det.toString(), contains('1.0 * 1.0'));
    });

    test('Characteristic Polynomial (2x2)', () {
      // [[2, 0], [0, 3]]
      // (2-L)(3-L) - 0 = 6 - 5L + L^2
      var m = SymbolicMatrix.fromStrings([
        ['2', '0'],
        ['0', '3']
      ]);
      Expression poly = m.characteristicPolynomial('L');
      String s = poly.simplify().toString();
      // Expected: (2 - L) * (3 - L)
      // math_expressions simplify is basic, might return (2.0 - L) * (3.0 - L)
      expect(s, contains('L'));
      expect(s, contains('2.0'));
      expect(s, contains('3.0'));
    });
    test('Symbolic Determinant (3x3)', () {
      // [[1, 0, 0], [0, x, 0], [0, 0, y]]
      // Det = 1 * x * y
      var m = SymbolicMatrix.fromStrings([
        ['1', '0', '0'],
        ['0', 'x', '0'],
        ['0', '0', 'y']
      ]);
      Expression det = m.determinant();
      String s = det.simplify().toString();
      // Expected: x * y or similar
      expect(s, contains('x'));
      expect(s, contains('y'));
    });

    test('Mixed Variables', () {
      // [[x, 1], [1, y]]
      // Det = x*y - 1
      var m = SymbolicMatrix.fromStrings([
        ['x', '1'],
        ['1', 'y']
      ]);
      Expression det = m.determinant();
      String s = det.simplify().toString();
      expect(s, contains('x'));
      expect(s, contains('y'));
      // Check for subtraction of 1
      // math_expressions might output ((x * y) - 1.0)
      expect(s, contains('1.0'));
    });
  });
}
