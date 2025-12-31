import 'package:flutter_test/flutter_test.dart';
import 'package:fraction/fraction.dart';
import 'package:matrix_calc_offline/logic/matrix.dart';
import 'package:matrix_calc_offline/logic/solvers.dart';

void main() {
  group('Additional Solvers', () {
    test('Cramer Solver', () {
      // 2x + y = 5
      // x - y = 1
      // Solution: x=2, y=1
      final A = Matrix.fromData([
        [Fraction(2), Fraction(1)],
        [Fraction(1), Fraction(-1)],
      ]);
      final b = [Fraction(5), Fraction(1)];
      
      final solver = CramerSolver();
      final steps = solver.solve(A, b);
      
      // Last step should contain the result
      final resultMatrix = steps.last.matrixState;
      expect(resultMatrix.get(0, 0), equals(Fraction(2)));
      expect(resultMatrix.get(1, 0), equals(Fraction(1)));
    });

    test('Inverse Matrix Solver', () {
      // 2x + y = 5
      // x - y = 1
      // Solution: x=2, y=1
      final A = Matrix.fromData([
        [Fraction(2), Fraction(1)],
        [Fraction(1), Fraction(-1)],
      ]);
      final b = [Fraction(5), Fraction(1)];
      
      final solver = InverseMatrixSolver();
      final steps = solver.solve(A, b);
      
      // Last step should contain the result
      final resultMatrix = steps.last.matrixState;
      expect(resultMatrix.get(0, 0), equals(Fraction(2)));
      expect(resultMatrix.get(1, 0), equals(Fraction(1)));
    });
  });
}
