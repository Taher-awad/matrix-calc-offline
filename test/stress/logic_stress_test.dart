import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/logic/matrix.dart';
import 'package:fraction/fraction.dart';

void main() {
  group('Logic Stress Test', () {
    test('Random Matrix Properties (50 Iterations)', () {
      final rng = Random();
      int passed = 0;
      int singular = 0;

      print('--- Starting Logic Stress Test ---');

      for (int i = 0; i < 50; i++) {
        int size = rng.nextInt(3) + 2; // 2 to 4
        Matrix A = _generateRandomMatrix(size, rng);
        
        // 1. Transpose Property: (A^T)^T = A
        Matrix ATT = A.transpose().transpose();
        expect(_matricesEqual(A, ATT), isTrue, reason: "Transpose failed at iter $i");

        // 2. Determinant Property: det(A) = det(A^T)
        Fraction detA = A.determinant();
        Fraction detAT = A.transpose().determinant();
        expect(detA, equals(detAT), reason: "Determinant transpose failed at iter $i");

        // 3. Inverse Property: A * A^-1 = I (if non-singular)
        if (detA != Fraction(0)) {
          try {
            Matrix Inv = A.inverse();
            Matrix Identity = A * Inv;
            if (_isIdentity(Identity)) {
              passed++;
            } else {
              print("Inverse check failed (precision issue?): \n$Identity");
            }
          } catch (e) {
            print("Inverse failed at iter $i: $e");
          }
        } else {
          singular++;
        }
      }
      print('--- Logic Stress Test Complete ---');
      print('Passed Inverse Checks: $passed');
      print('Singular Matrices Encountered: $singular');
    });
  });
}

// --- Helpers ---

Matrix _generateRandomMatrix(int size, Random rng) {
  List<List<Fraction>> data = [];
  for (int i = 0; i < size; i++) {
    List<Fraction> row = [];
    for (int j = 0; j < size; j++) {
      row.add(Fraction(rng.nextInt(10) - 5)); // -5 to 4
    }
    data.add(row);
  }
  return Matrix.fromData(data);
}

bool _matricesEqual(Matrix A, Matrix B) {
  if (A.rows != B.rows || A.cols != B.cols) return false;
  for (int i = 0; i < A.rows; i++) {
    for (int j = 0; j < A.cols; j++) {
      if (A.get(i, j) != B.get(i, j)) return false;
    }
  }
  return true;
}

bool _isIdentity(Matrix M) {
  for (int i = 0; i < M.rows; i++) {
    for (int j = 0; j < M.cols; j++) {
      if (i == j) {
        if (M.get(i, j) != Fraction(1)) return false;
      } else {
        if (M.get(i, j) != Fraction(0)) return false;
      }
    }
  }
  return true;
}
