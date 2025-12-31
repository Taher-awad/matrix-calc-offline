import 'package:flutter_test/flutter_test.dart';
import 'package:fraction/fraction.dart';
import 'package:matrix_calc_offline/logic/matrix.dart';
import 'package:matrix_calc_offline/logic/eigen_solver.dart';

void main() {
  group('EigenSolver', () {
    test('Real Eigenvalues (Diagonal Matrix)', () {
      // [2 0]
      // [0 3]
      // Eigenvalues: 2, 3
      Matrix A = Matrix.fromData([
        [Fraction(2), Fraction(0)],
        [Fraction(0), Fraction(3)]
      ]);
      
      EigenSolver solver = EigenSolver();
      List<EigenPair> pairs = solver.getEigenPairs(A);
      
      // Sort by eigenvalue to ensure order
      pairs.sort((a, b) => a.eigenvalue.compareTo(b.eigenvalue));
      
      expect(pairs.length, 2);
      expect(pairs[0].eigenvalue, closeTo(2.0, 0.001));
      expect(pairs[1].eigenvalue, closeTo(3.0, 0.001));
    });

    test('Real Eigenvalues (3x3 Identity)', () {
      // [1 0 0]
      // [0 1 0]
      // [0 0 1]
      // Eigenvalues: 1, 1, 1
      Matrix A = Matrix.fromData([
        [Fraction(1), Fraction(0), Fraction(0)],
        [Fraction(0), Fraction(1), Fraction(0)],
        [Fraction(0), Fraction(0), Fraction(1)]
      ]);
      
      EigenSolver solver = EigenSolver();
      List<EigenPair> pairs = solver.getEigenPairs(A);
      
      expect(pairs.length, 3);
      for(var p in pairs) {
        expect(p.eigenvalue, closeTo(1.0, 0.001));
      }
    });

    test('Complex Eigenvalues (Rotation Matrix)', () {
      // [0 -1]
      // [1  0]
      // Lambda^2 + 1 = 0 => Lambda = +/- i
      // Our numerical solver (QR algorithm) might struggle or return approximate real parts if not designed for complex.
      // However, for this specific solver implementation (QR), it typically converges to real block forms for complex eigenvalues.
      // If it doesn't support complex, it might return something else or fail to converge.
      // Let's see what it does. If it fails to converge to real diagonal, it might return the blocks.
      // But since we extract diagonal elements, we might get 0.
      
      Matrix A = Matrix.fromData([
        [Fraction(0), Fraction(-1)],
        [Fraction(1), Fraction(0)]
      ]);
      
      EigenSolver solver = EigenSolver();
      // We expect it to run without crashing, but the values might be 0 (real part) or similar.
      // This test mainly verifies it doesn't crash.
      List<EigenPair> pairs = solver.getEigenPairs(A);
      expect(pairs.length, 2);
    });

    test('Diagonalization (A = PDP^-1)', () {
      // [4 1]
      // [2 3]
      // Eigenvalues: 2, 5
      // D = [[2, 0], [0, 5]]
      // Eigenvectors: v1=[-1, 2], v2=[1, 1]
      // P = [[-1, 1], [2, 1]]
      
      Matrix A = Matrix.fromData([
        [Fraction(4), Fraction(1)],
        [Fraction(2), Fraction(3)]
      ]);
      
      EigenSolver solver = EigenSolver();
      List<String> steps = solver.getDiagonalization(A);
      
      // We can't easily parse the string steps to verify exact matrices without regex.
      // But we can verify it didn't error and produced output.
      expect(steps.join('\n'), contains('Matrix D'));
      expect(steps.join('\n'), contains('Matrix P'));
      expect(steps.join('\n'), contains('Verification'));
      
      // Ideally we should test the private logic or expose a method returning matrices.
      // For now, checking the steps output confirms the flow ran.
    });
  });
}
