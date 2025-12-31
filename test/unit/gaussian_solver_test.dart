import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/logic/matrix.dart';
import 'package:matrix_calc_offline/logic/solvers.dart';
import 'package:fraction/fraction.dart';

void main() {
  group('GaussianSolver', () {
    test('Solves 2x2 system correctly', () {
      // x + y = 3
      // x - y = 1
      // Solution: x=2, y=1
      Matrix coeffs = Matrix(2, 2);
      coeffs.set(0, 0, Fraction(1)); coeffs.set(0, 1, Fraction(1));
      coeffs.set(1, 0, Fraction(1)); coeffs.set(1, 1, Fraction(-1));
      
      List<Fraction> constants = [Fraction(3), Fraction(1)];
      
      GaussianSolver solver = GaussianSolver();
      var steps = solver.solve(coeffs, constants);
      
      // Check last step is Back Substitution
      expect(steps.last.description, contains("Back Substitution Result"));
      
      Matrix result = steps.last.matrixState!;
      expect(result.rows, 2);
      expect(result.cols, 1);
      expect(result.get(0, 0), Fraction(2)); // x
      expect(result.get(1, 0), Fraction(1)); // y
    });

    test('Solves 3x3 system with zeros (underdetermined/consistent) correctly', () {
      // x + y = 3
      // x - y = 1
      // 0 = 0
      // Should give x=2, y=1, z=0 (free var set to 0)
      Matrix coeffs = Matrix(3, 3);
      coeffs.set(0, 0, Fraction(1)); coeffs.set(0, 1, Fraction(1));
      coeffs.set(1, 0, Fraction(1)); coeffs.set(1, 1, Fraction(-1));
      // Row 2 is all zeros
      
      List<Fraction> constants = [Fraction(3), Fraction(1), Fraction(0)];
      
      GaussianSolver solver = GaussianSolver();
      var steps = solver.solve(coeffs, constants);
      
      expect(steps.last.description, contains("Back Substitution Result"));
      
      Matrix result = steps.last.matrixState!;
      expect(result.get(0, 0), Fraction(2));
      expect(result.get(1, 0), Fraction(1));
      expect(result.get(2, 0), Fraction(0));
    });
  });
}
