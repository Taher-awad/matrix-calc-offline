import 'package:fraction/fraction.dart';
import 'matrix.dart';
import 'solution_step.dart';

abstract class LinearSolver {
  List<SolutionStep> solve(Matrix coefficients, List<Fraction> constants);
}

class GaussianSolver implements LinearSolver {
  @override
  List<SolutionStep> solve(Matrix coefficients, List<Fraction> constants) {
    // Augment the matrix
    int rows = coefficients.rows;
    int cols = coefficients.cols;
    Matrix augmented = Matrix(rows, cols + 1);
    
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        augmented.set(i, j, coefficients.get(i, j));
      }
      augmented.set(i, cols, constants[i]);
    }

    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Initial Augmented Matrix", augmented.clone()));

    int pivotRow = 0;
    for (int j = 0; j < cols && pivotRow < rows; j++) {
      // Find pivot
      int maxRow = pivotRow;
      // Helper for abs value comparison
      Fraction maxVal = augmented.get(maxRow, j);
      if (maxVal.isNegative) maxVal = maxVal * Fraction(-1);

      for (int i = pivotRow + 1; i < rows; i++) {
        Fraction currentVal = augmented.get(i, j);
        if (currentVal.isNegative) currentVal = currentVal * Fraction(-1);
        
        if (currentVal > maxVal) {
          maxRow = i;
          maxVal = currentVal;
        }
      }

      if (augmented.get(maxRow, j) == Fraction(0)) {
        continue; // Column is all zeros
      }

      // Swap rows
      if (maxRow != pivotRow) {
        augmented.swapRows(pivotRow, maxRow);
        steps.add(SolutionStep(
            "Swap row ${pivotRow + 1} with row ${maxRow + 1}", augmented.clone()));
      }

      // Normalize pivot row
      Fraction pivot = augmented.get(pivotRow, j);
      if (pivot != Fraction(1)) {
        augmented.multiplyRow(pivotRow, Fraction(1) / pivot);
        steps.add(SolutionStep(
            "Divide row ${pivotRow + 1} by $pivot", augmented.clone()));
      }

      // Eliminate other rows
      for (int i = 0; i < rows; i++) {
        if (i != pivotRow) {
          Fraction factor = augmented.get(i, j);
          if (factor != Fraction(0)) {
            // Use factor * -1 instead of -factor
            augmented.addRow(i, pivotRow, factor * Fraction(-1));
            steps.add(SolutionStep(
                "Subtract $factor * row ${pivotRow + 1} from row ${i + 1}",
                augmented.clone()));
          }
        }
      }
      pivotRow++;
    }
    // Back Substitution
    try {
      Matrix solution = Matrix(rows, 1);
      for (int i = rows - 1; i >= 0; i--) {
        Fraction sum = Fraction(0);
        for (int j = i + 1; j < rows; j++) {
          sum += augmented.get(i, j) * solution.get(j, 0);
        }
        Fraction val = augmented.get(i, cols); // Constant term
        Fraction coeff = augmented.get(i, i);
        
        if (coeff == Fraction(0)) {
           if (val != Fraction(0) - sum) {
             // Inconsistent
             steps.add(SolutionStep("System is inconsistent (0 != $val). No solution."));
             return steps;
           } else {
             // Free variable. Let's set to 0 for simplicity or handle it.
             // For now, set to 0.
             solution.set(i, 0, Fraction(0));
           }
        } else {
          solution.set(i, 0, (val - sum) / coeff);
        }
      }
      steps.add(SolutionStep("Back Substitution Result (Solution Vector)", solution));
    } catch (e) {
      steps.add(SolutionStep("Error during back substitution: $e"));
    }

    return steps;
  }
}

class CramerSolver implements LinearSolver {
  @override
  List<SolutionStep> solve(Matrix coefficients, List<Fraction> constants) {
    List<SolutionStep> steps = [];
    
    Fraction detA = coefficients.determinant();
    steps.add(SolutionStep("Calculate Determinant of Main Matrix (Delta)", coefficients.clone()));
    steps.add(SolutionStep("Delta = $detA", coefficients.clone()));

    if (detA == Fraction(0)) {
      throw Exception("Determinant is 0. System has no unique solution.");
    }

    int n = coefficients.rows;
    List<Fraction> results = [];

    for (int i = 0; i < n; i++) {
      Matrix Ai = coefficients.clone();
      // Replace column i with constants
      for (int r = 0; r < n; r++) {
        Ai.set(r, i, constants[r]);
      }
      
      Fraction detAi = Ai.determinant();
      steps.add(SolutionStep("Calculate Determinant of Matrix Delta_$i (replace column ${i+1} with constants)", Ai.clone()));
      steps.add(SolutionStep("Delta_$i = $detAi", Ai.clone()));
      
      Fraction xi = detAi / detA;
      results.add(xi);
      steps.add(SolutionStep("x_${i+1} = Delta_$i / Delta = $detAi / $detA = $xi", Ai.clone()));
    }

    // Create a final matrix to show results
    Matrix resultMatrix = Matrix(n, 1);
    for(int i=0; i<n; i++) {
      resultMatrix.set(i, 0, results[i]);
    }
    steps.add(SolutionStep("Final Solution", resultMatrix));

    return steps;
  }
}

class InverseMatrixSolver implements LinearSolver {
  @override
  List<SolutionStep> solve(Matrix coefficients, List<Fraction> constants) {
    List<SolutionStep> steps = [];
    
    steps.add(SolutionStep("Initial System Matrix A", coefficients.clone()));
    
    // 1. Find Inverse
    Matrix inverse;
    try {
      inverse = coefficients.inverse();
      steps.add(SolutionStep("Calculate Inverse Matrix A^-1", inverse.clone()));
    } catch (e) {
      throw Exception("Matrix is singular. Cannot solve using Inverse Matrix method.");
    }

    // 2. Multiply A^-1 * B
    // Convert constants list to Matrix (n x 1)
    Matrix B = Matrix(constants.length, 1);
    for(int i=0; i<constants.length; i++) {
      B.set(i, 0, constants[i]);
    }
    
    steps.add(SolutionStep("Constants Vector B", B.clone()));
    
    Matrix X = inverse * B;
    steps.add(SolutionStep("Calculate X = A^-1 * B", X.clone()));
    
    return steps;
  }
}
class GaussJordanSolver implements LinearSolver {
  @override
  List<SolutionStep> solve(Matrix coefficients, List<Fraction> constants) {
    // Gauss-Jordan is similar to Gaussian but continues to reduce to RREF
    // For simplicity, we can reuse Gaussian logic or implement RREF directly.
    // Let's implement RREF on the augmented matrix.
    
    int rows = coefficients.rows;
    int cols = coefficients.cols;
    Matrix augmented = Matrix(rows, cols + 1);
    
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        augmented.set(i, j, coefficients.get(i, j));
      }
      augmented.set(i, cols, constants[i]);
    }

    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Initial Augmented Matrix", augmented.clone()));

    // Forward Elimination (Gaussian)
    int pivotRow = 0;
    for (int j = 0; j < cols && pivotRow < rows; j++) {
      int maxRow = pivotRow;
      Fraction maxVal = augmented.get(maxRow, j);
      if (maxVal.isNegative) maxVal = maxVal * Fraction(-1);
      
      for (int i = pivotRow + 1; i < rows; i++) {
        Fraction currentVal = augmented.get(i, j);
        Fraction absCurrent = currentVal.isNegative ? currentVal * Fraction(-1) : currentVal;
        
        if (absCurrent > maxVal) {
          maxRow = i;
          maxVal = absCurrent;
        }
      }

      if (augmented.get(maxRow, j) == Fraction(0)) continue;

      if (maxRow != pivotRow) {
        augmented.swapRows(pivotRow, maxRow);
        steps.add(SolutionStep("Swap row ${pivotRow + 1} with row ${maxRow + 1}", augmented.clone()));
      }

      Fraction pivot = augmented.get(pivotRow, j);
      if (pivot != Fraction(1)) {
        augmented.multiplyRow(pivotRow, Fraction(1) / pivot);
        steps.add(SolutionStep("Divide row ${pivotRow + 1} by $pivot", augmented.clone()));
      }

      for (int i = 0; i < rows; i++) {
        if (i != pivotRow) {
          Fraction factor = augmented.get(i, j);
          if (factor != Fraction(0)) {
            augmented.addRow(i, pivotRow, factor * Fraction(-1));
            steps.add(SolutionStep("Subtract $factor * row ${pivotRow + 1} from row ${i + 1}", augmented.clone()));
          }
        }
      }
      pivotRow++;
    }
    
    steps.add(SolutionStep("Reduced Row Echelon Form (Gauss-Jordan Complete)", augmented.clone()));
    
    // Extract solution
    Matrix result = Matrix(rows, 1);
    for(int i=0; i<rows; i++) {
        result.set(i, 0, augmented.get(i, cols));
    }
    steps.add(SolutionStep("Final Solution Vector", result));

    return steps;
  }
}

class LeastSquaresSolver implements LinearSolver {
  @override
  List<SolutionStep> solve(Matrix coefficients, List<Fraction> constants) {
    // Solve A^T * A * x = A^T * b
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Initial System Ax = b", coefficients.clone()));
    
    Matrix A = coefficients;
    Matrix AT = A.transpose();
    steps.add(SolutionStep("Calculate Transpose A^T", AT.clone()));
    
    Matrix ATA = AT * A;
    steps.add(SolutionStep("Calculate Normal Matrix A^T * A", ATA.clone()));
    
    // Convert constants to Matrix B
    Matrix B = Matrix(constants.length, 1);
    for(int i=0; i<constants.length; i++) {
      B.set(i, 0, constants[i]);
    }
    
    Matrix ATB = AT * B;
    steps.add(SolutionStep("Calculate A^T * b", ATB.clone()));
    
    // Now solve (ATA) * x = (ATB)
    // We can use Gaussian elimination or Inverse. Let's use Inverse for steps.
    try {
      Matrix ATAInv = ATA.inverse();
      steps.add(SolutionStep("Calculate Inverse (A^T * A)^-1", ATAInv.clone()));
      
      Matrix X = ATAInv * ATB;
      steps.add(SolutionStep("Calculate x = (A^T * A)^-1 * (A^T * b)", X.clone()));
      return steps;
    } catch (e) {
      throw Exception("Normal matrix is singular. Cannot solve Least Squares unique solution.");
    }
  }
}
