import 'package:flutter_test/flutter_test.dart';
import 'package:fraction/fraction.dart';
import 'package:matrix_calc_offline/logic/matrix.dart';

void main() {
  group('Matrix Operations', () {
    test('Addition', () {
      Matrix A = Matrix.fromData([
        [Fraction(1), Fraction(2)],
        [Fraction(3), Fraction(4)]
      ]);
      Matrix B = Matrix.fromData([
        [Fraction(5), Fraction(6)],
        [Fraction(7), Fraction(8)]
      ]);
      Matrix C = A + B;
      expect(C.get(0, 0), Fraction(6));
      expect(C.get(1, 1), Fraction(12));
    });

    test('Multiplication (Matrix * Matrix)', () {
      Matrix A = Matrix.fromData([
        [Fraction(1), Fraction(2)],
        [Fraction(3), Fraction(4)]
      ]);
      Matrix B = Matrix.fromData([
        [Fraction(2), Fraction(0)],
        [Fraction(1), Fraction(2)]
      ]);
      Matrix C = A * B;
      // [1*2+2*1, 1*0+2*2] = [4, 4]
      // [3*2+4*1, 3*0+4*2] = [10, 8]
      expect(C.get(0, 0), Fraction(4));
      expect(C.get(0, 1), Fraction(4));
      expect(C.get(1, 0), Fraction(10));
      expect(C.get(1, 1), Fraction(8));
    });

    test('Scalar Multiplication', () {
      Matrix A = Matrix.fromData([
        [Fraction(1), Fraction(-2)],
        [Fraction(3), Fraction(4)]
      ]);
      Matrix C = A * Fraction(2);
      expect(C.get(0, 0), Fraction(2));
      expect(C.get(0, 1), Fraction(-4));
      expect(C.get(1, 0), Fraction(6));
      expect(C.get(1, 1), Fraction(8));
    });

    test('Matrix Power', () {
      Matrix A = Matrix.fromData([
        [Fraction(1), Fraction(1)],
        [Fraction(0), Fraction(1)]
      ]);
      // A^2 = [[1, 2], [0, 1]]
      // A^3 = [[1, 3], [0, 1]]
      Matrix C = A.pow(3);
      expect(C.get(0, 0), Fraction(1));
      expect(C.get(0, 1), Fraction(3));
      expect(C.get(1, 0), Fraction(0));
      expect(C.get(1, 1), Fraction(1));
    });

    test('Determinant', () {
      Matrix A = Matrix.fromData([
        [Fraction(1), Fraction(2)],
        [Fraction(3), Fraction(4)]
      ]);
      // 1*4 - 2*3 = 4 - 6 = -2
      expect(A.determinant(), Fraction(-2));
    });

    test('Inverse', () {
      Matrix A = Matrix.fromData([
        [Fraction(4), Fraction(7)],
        [Fraction(2), Fraction(6)]
      ]);
      // Det = 24 - 14 = 10
      // Inv = 1/10 * [[6, -7], [-2, 4]]
      Matrix Inv = A.inverse();
      expect(Inv.get(0, 0), Fraction(6, 10)); // 3/5
      expect(Inv.get(0, 1), Fraction(-7, 10));
    });

    test('Triangular Form (Row Echelon)', () {
      Matrix A = Matrix.fromData([
        [Fraction(1), Fraction(2), Fraction(3)],
        [Fraction(2), Fraction(5), Fraction(7)],
        [Fraction(3), Fraction(8), Fraction(12)] // Dependent row? No.
      ]);
      /*
      R2 = R2 - 2R1 => [0, 1, 1]
      R3 = R3 - 3R1 => [0, 2, 3]
      R3 = R3 - 2R2 => [0, 0, 1]
      Result:
      [1, 2, 3]
      [0, 1, 1]
      [0, 0, 1]
      */
      Matrix T = A.triangleForm();
      expect(T.get(1, 0), Fraction(0));
      expect(T.get(2, 0), Fraction(0));
      expect(T.get(2, 1), Fraction(0));
      expect(T.get(0, 0), Fraction(1));
      expect(T.get(1, 1), Fraction(1));
      expect(T.get(2, 2), Fraction(1));
    });
    test('Singular Matrix Inversion (Should Throw)', () {
      Matrix A = Matrix.fromData([
        [Fraction(1), Fraction(2)],
        [Fraction(2), Fraction(4)]
      ]);
      // Det = 4 - 4 = 0
      expect(() => A.inverse(), throwsException);
    });

    test('Non-Square Determinant (Should Throw)', () {
      Matrix A = Matrix.fromData([
        [Fraction(1), Fraction(2), Fraction(3)],
        [Fraction(4), Fraction(5), Fraction(6)]
      ]);
      expect(() => A.determinant(), throwsException);
    });

    test('Multiplication Dimension Mismatch (Should Throw)', () {
      Matrix A = Matrix(2, 2);
      Matrix B = Matrix(3, 3);
      expect(() => A * B, throwsException);
    });

    test('Addition Dimension Mismatch (Should Throw)', () {
      Matrix A = Matrix(2, 2);
      Matrix B = Matrix(2, 3);
      expect(() => A + B, throwsException);
    });

    test('Zero and Negative Scalar Multiplication', () {
      Matrix A = Matrix.fromData([
        [Fraction(1), Fraction(-2)],
        [Fraction(3), Fraction(0)]
      ]);
      
      Matrix Z = A * Fraction(0);
      expect(Z.get(0, 0), Fraction(0));
      expect(Z.get(1, 1), Fraction(0));

      Matrix N = A * Fraction(-1);
      expect(N.get(0, 0), Fraction(-1));
      expect(N.get(0, 1), Fraction(2));
    });
  });
}
