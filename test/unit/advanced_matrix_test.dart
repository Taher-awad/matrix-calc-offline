import 'package:flutter_test/flutter_test.dart';
import 'package:fraction/fraction.dart';
import 'package:matrix_calc_offline/logic/matrix.dart';

void main() {
  group('Advanced Matrix Tests', () {
    test('Determinant Consistency (Gaussian vs Montante vs Laplace)', () {
      // 3x3 Matrix
      // [ 2  -1   0 ]
      // [ 1   3   4 ]
      // [ 5   2   1 ]
      // Det = 2(3-8) - (-1)(1-20) + 0 = 2(-5) + 1(-19) = -10 - 19 = -29
      
      final data = [
        [Fraction(2), Fraction(-1), Fraction(0)],
        [Fraction(1), Fraction(3), Fraction(4)],
        [Fraction(5), Fraction(2), Fraction(1)],
      ];
      final matrix = Matrix.fromData(data);
      
      final detGauss = matrix.determinant();
      final detMontante = matrix.determinantMontante();
      final detLaplaceRow0 = matrix.determinantLaplace(0, true);
      final detLaplaceCol1 = matrix.determinantLaplace(1, false);
      
      expect(detGauss, equals(Fraction(-29)));
      expect(detMontante, equals(Fraction(-29)));
      expect(detLaplaceRow0, equals(Fraction(-29)));
      expect(detLaplaceCol1, equals(Fraction(-29)));
    });

    test('Rank Deficient Matrix', () {
      // Row 2 is 2 * Row 1
      // [ 1  2 ]
      // [ 2  4 ]
      // Rank should be 1
      final matrix = Matrix.fromData([
        [Fraction(1), Fraction(2)],
        [Fraction(2), Fraction(4)],
      ]);
      
      expect(matrix.rank(), equals(1));
    });

    test('Matrix Power', () {
      final matrix = Matrix.fromData([
        [Fraction(2), Fraction(0)],
        [Fraction(0), Fraction(3)],
      ]);
      
      // A^0 = I
      final pow0 = matrix.pow(0);
      expect(pow0.get(0, 0), equals(Fraction(1)));
      expect(pow0.get(1, 1), equals(Fraction(1)));
      
      // A^2 = [4 0; 0 9]
      final pow2 = matrix.pow(2);
      expect(pow2.get(0, 0), equals(Fraction(4)));
      expect(pow2.get(1, 1), equals(Fraction(9)));
    });

    test('RREF Logic', () {
      // [ 1  2  3 ]
      // [ 2  5  7 ]
      // RREF:
      // [ 1  0  1 ]
      // [ 0  1  1 ]
      
      final matrix = Matrix.fromData([
        [Fraction(1), Fraction(2), Fraction(3)],
        [Fraction(2), Fraction(5), Fraction(7)],
      ]);
      
      final rref = matrix.rref();
      
      expect(rref.get(0, 0), equals(Fraction(1)));
      expect(rref.get(0, 1), equals(Fraction(0)));
      expect(rref.get(0, 2), equals(Fraction(1)));
      
      expect(rref.get(1, 0), equals(Fraction(0)));
      expect(rref.get(1, 1), equals(Fraction(1)));
      expect(rref.get(1, 2), equals(Fraction(1)));
    });
  });
}
