import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/logic/matrix.dart';
import 'package:matrix_calc_offline/logic/eigen_solver.dart';
import 'package:matrix_calc_offline/logic/solution_step.dart';
import 'package:fraction/fraction.dart';

void main() {
  test('Diagonalization freeze reproduction', () {
    // 1. Identity Matrix (Simple)
    Matrix I = Matrix(3, 3);
    for(int i=0; i<3; i++) {
      I.set(i, i, Fraction(1));
    }
    EigenSolver().getDiagonalization(I);

    // 2. Matrix with real eigenvalues
    Matrix A = Matrix.fromData([
      [Fraction(4), Fraction(1)],
      [Fraction(2), Fraction(3)]
    ]); // Eigenvalues 2, 5
    EigenSolver().getDiagonalization(A);

    // 3. Matrix with complex eigenvalues (Rotation)
    // [0 -1]
    // [1  0]
    // Eigenvalues +/- i. QR algorithm on doubles might struggle or produce garbage.
    Matrix Rot = Matrix.fromData([
      [Fraction(0), Fraction(-1)],
      [Fraction(1), Fraction(0)]
    ]);
    EigenSolver().getDiagonalization(Rot);

    // 4. Defective Matrix (Shear)
    // [1 1]
    // [0 1]
    // Eigenvalue 1 (multiplicity 2), only 1 eigenvector.
    Matrix Shear = Matrix.fromData([
      [Fraction(1), Fraction(1)],
      [Fraction(0), Fraction(1)]
    ]);
    EigenSolver().getDiagonalization(Shear);
    
    // 5. Larger Random Matrix
    // 5x5
    Matrix Large = Matrix(5, 5);
    for(int i=0; i<5; i++) {
      for(int j=0; j<5; j++) {
        Large.set(i, j, Fraction(i+j));
      }
    }
    EigenSolver().getDiagonalization(Large);

    // 6. Irrational Eigenvalues
    // [1 2]
    // [1 1]
    // Eigenvalues 1 +/- sqrt(2)
    Matrix Irrational = Matrix.fromData([
      [Fraction(1), Fraction(2)],
      [Fraction(1), Fraction(1)]
    ]);
    Stopwatch sw = Stopwatch()..start();
    EigenSolver().getDiagonalization(Irrational);
    print("Irrational diagonalization took: ${sw.elapsedMilliseconds}ms");
    
    // 7. Large Irrational
    // Symmetric matrix ensures real eigenvalues, likely irrational
    Matrix Sym = Matrix(5, 5);
    for(int i=0; i<5; i++) {
      for(int j=0; j<=i; j++) {
        Sym.set(i, j, Fraction(i*j + 1));
        Sym.set(j, i, Fraction(i*j + 1));
      }
    }
    sw.reset();
    List<SolutionStep> steps = EigenSolver().getDiagonalization(Sym);
    print("Large Symmetric diagonalization took: ${sw.elapsedMilliseconds}ms");
    
    for(var step in steps) {
      if (step.matrixState != null) {
        print("Matrix in step: ${step.description}");
        for(int i=0; i<step.matrixState!.rows; i++) {
          for(int j=0; j<step.matrixState!.cols; j++) {
            Fraction f = step.matrixState!.get(i, j);
            if (f.numerator > 10000 || f.denominator > 10000) {
              // print("Large fraction found at ($i, $j): $f");
            }
          }
        }
      }
    }
    
    // Measure P.inverse manually
    // Extract P from steps (it's the 2nd matrix in steps usually, or find by description)
    Matrix? P;
    for(var step in steps) {
      if (step.description.contains("Matrix P (Eigenvectors")) {
        P = step.matrixState;
        break;
      }
    }
    
    if (P != null) {
      sw.reset();
      try {
        Matrix PInv = P.inverse();
        print("P.inverse() took: ${sw.elapsedMilliseconds}ms");
      } catch (e) {
        print("P.inverse() failed as expected: $e");
      }
      
      sw.reset();
      // Matrix D is previous step
      // But let's just check inverse cost first.
    }
  });
}
