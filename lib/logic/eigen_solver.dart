import 'dart:math';
import 'package:fraction/fraction.dart';
import 'package:math_expressions/math_expressions.dart';
import 'matrix.dart';
import 'symbolic_matrix.dart';
import 'solution_step.dart';

class EigenPair {
  final double eigenvalue;
  final List<double> eigenvector;

  EigenPair(this.eigenvalue, this.eigenvector);
}

class EigenSolver {
  // Numerical approach using QR Algorithm for eigenvalues
  // and Inverse Iteration for eigenvectors
  
  Fraction _toFraction(double val) {
    // Use a reasonable precision to avoid huge denominators
    // and potential freezes during rendering or verification.
    try {
      return Fraction.fromDouble(val, precision: 1.0e-4);
    } catch (e) {
      // Fallback if conversion fails (e.g. NaN, Infinity)
      return Fraction(0);
    }
  }

  List<EigenPair> getEigenPairs(Matrix matrix) {
    if (matrix.rows != matrix.cols) throw Exception("Matrix must be square");
    
    // 1. Find Eigenvalues using QR
    List<double> eigenvalues = _getEigenvaluesQR(matrix);
    
    // 2. Find Eigenvectors for each eigenvalue
    List<EigenPair> pairs = [];
    int n = matrix.rows;
    
    // Convert Matrix to double[][]
    List<List<double>> A = List.generate(n, (i) => List.generate(n, (j) => matrix.get(i, j).toDouble()));

    for (double lambda in eigenvalues) {
      List<double> vector = _inverseIteration(A, lambda);
      pairs.add(EigenPair(lambda, vector));
    }
    
    return pairs;
  }

  List<double> _getEigenvaluesQR(Matrix matrix) {
    int n = matrix.rows;
    List<List<double>> A = List.generate(n, (i) => List.generate(n, (j) => matrix.get(i, j).toDouble()));

    for (int iter = 0; iter < 100; iter++) {
      // QR Decomposition
      List<List<double>> Q = List.generate(n, (_) => List.filled(n, 0.0));
      List<List<double>> R = List.generate(n, (_) => List.filled(n, 0.0));
      
      for (int j = 0; j < n; j++) {
        List<double> v = List.generate(n, (i) => A[i][j]);
        for (int i = 0; i < j; i++) {
          double dot = 0;
          for (int k = 0; k < n; k++) {
            dot += Q[k][i] * A[k][j];
          }
          R[i][j] = dot;
          for (int k = 0; k < n; k++) {
            v[k] -= R[i][j] * Q[k][i];
          }
        }
        double norm = 0;
        for (int k = 0; k < n; k++) {
          norm += v[k] * v[k];
        }
        norm = sqrt(norm);
        R[j][j] = norm;
        for (int k = 0; k < n; k++) {
          Q[k][j] = v[k] / (norm == 0 ? 1 : norm);
        }
      }
      
      List<List<double>> nextA = List.generate(n, (_) => List.filled(n, 0.0));
      for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
          double sum = 0;
          for (int k = 0; k < n; k++) {
            sum += R[i][k] * Q[k][j];
          }
          nextA[i][j] = sum;
        }
      }
      A = nextA;
      
      bool converged = true;
      for (int i = 0; i < n; i++) {
        for (int j = 0; j < i; j++) {
          if (A[i][j].abs() > 1e-6) {
            converged = false;
            break;
          }
        }
      }
      if (converged) break;
    }

    List<double> evs = [];
    for (int i = 0; i < n; i++) {
      evs.add(A[i][i]);
    }
    return evs;
  }

  List<double> _inverseIteration(List<List<double>> A, double eigenvalue) {
    int n = A.length;
    // (A - lambda*I)v = 0
    // We solve (A - (lambda + epsilon)I)x = b iteratively
    // Use a small shift to avoid singularity if lambda is exact
    double shift = eigenvalue + 1e-8; 
    
    // Matrix M = A - shift*I
    List<List<double>> M = List.generate(n, (i) => List.from(A[i]));
    for(int i=0; i<n; i++) {
      M[i][i] -= shift;
    }

    // Initial random vector
    List<double> v = List.generate(n, (_) => Random().nextDouble());
    // Normalize
    double norm = sqrt(v.map((e) => e*e).reduce((a,b) => a+b));
    for(int i=0; i<n; i++) {
      v[i] /= norm;
    }

    for(int iter=0; iter<10; iter++) {
      // Solve M*next_v = v using Gaussian elimination
      List<double> nextV = _solveSystem(M, v);
      
      // Normalize
      norm = sqrt(nextV.map((e) => e*e).reduce((a,b) => a+b));
      if (norm < 1e-10) break; // Avoid div by zero
      for(int i=0; i<n; i++) {
        v[i] = nextV[i] / norm;
      }
    }
    return v;
  }

  // Helper to convert standard Matrix to SymbolicMatrix for polynomial generation
  SymbolicMatrix _toSymbolic(Matrix m) {
    List<List<Expression>> data = [];
    for(int i=0; i<m.rows; i++) {
      List<Expression> row = [];
      for(int j=0; j<m.cols; j++) {
        // We only have numeric matrices here, so convert Fraction to Number
        row.add(Number(m.get(i, j).toDouble()));
      }
      data.add(row);
    }
    return SymbolicMatrix.fromData(data);
  }

  List<SolutionStep> getStepByStepSolution(Matrix matrix) {
    List<SolutionStep> steps = [];
    int n = matrix.rows;

    if (n != 2 && n != 3) {
      steps.add(SolutionStep("Step-by-step solution is currently available only for 2x2 and 3x3 matrices."));
      return steps;
    }

    steps.add(SolutionStep("1. Find the Characteristic Polynomial\nThe characteristic polynomial is given by det(A - λI) = 0."));
    
    // Use SymbolicMatrix to generate the exact polynomial
    SymbolicMatrix symMatrix = _toSymbolic(matrix);
    Expression poly = symMatrix.characteristicPolynomial('λ');
    steps.add(SolutionStep("Characteristic Equation:\n${poly.simplify()} = 0"));

    if (n == 2) {
      // 2x2 Case
      Fraction a = matrix.get(0, 0);
      Fraction b = matrix.get(0, 1);
      Fraction c = matrix.get(1, 0);
      Fraction d = matrix.get(1, 1);

      Fraction trace = a + d;
      Fraction det = a * d - b * c;

      steps.add(SolutionStep("Verification for 2x2:\nTrace (tr) = $trace\nDeterminant (det) = $det\nEquation: λ² - ($trace)λ + ($det) = 0"));

      // Solve Quadratic
      double trVal = trace.toDouble();
      double detVal = det.toDouble();
      double discriminant = trVal * trVal - 4 * detVal;

      List<double> lambdas = [];
      if (discriminant >= 0) {
        double l1 = (trVal + sqrt(discriminant)) / 2;
        double l2 = (trVal - sqrt(discriminant)) / 2;
        lambdas.add(l1);
        if ((l1 - l2).abs() > 1e-9) lambdas.add(l2);
        
        steps.add(SolutionStep("2. Find Eigenvalues (Roots)\nUsing quadratic formula:\nλ = ($trVal ± √$discriminant) / 2\nEigenvalues: ${lambdas.map((e) => e.toStringAsFixed(2)).join(", ")}"));
      } else {
        steps.add(SolutionStep("Discriminant is negative ($discriminant). Eigenvalues are complex."));
        return steps;
      }

      steps.add(SolutionStep("3. Find Eigenvectors"));
      for (double lambda in lambdas) {
        // Calculate eigenvector using inverse iteration
        List<List<double>> aDbl = List.generate(n, (i) => List.generate(n, (j) => matrix.get(i, j).toDouble()));
        List<double> vec = _inverseIteration(aDbl, lambda);
        
        // Convert vector to Matrix for display
        Matrix vecMat = Matrix(n, 1);
        for(int i=0; i<n; i++) {
          vecMat.set(i, 0, _toFraction(vec[i]));
        }
        
        steps.add(SolutionStep("For λ = ${lambda.toStringAsFixed(2)}:\nSolve (A - λI)v = 0\nEigenvector:", vecMat));
      }

    } else {
      // 3x3 Case
      Fraction trace = matrix.get(0,0) + matrix.get(1,1) + matrix.get(2,2);
      Fraction det = matrix.determinant();
      
      steps.add(SolutionStep("Verification for 3x3:\nTrace = $trace\nDeterminant = $det"));

      List<double> lambdas = _getEigenvaluesQR(matrix);
      // Filter duplicates roughly
      List<double> uniqueLambdas = [];
      for(var l in lambdas) {
        if (!uniqueLambdas.any((ul) => (ul - l).abs() < 1e-4)) {
          uniqueLambdas.add(l);
        }
      }
      steps.add(SolutionStep("2. Find Eigenvalues\nSolving cubic equation (using numerical method)...\nEigenvalues: ${uniqueLambdas.map((e) => e.toStringAsFixed(2)).join(", ")}"));

      steps.add(SolutionStep("3. Find Eigenvectors"));
      for (double lambda in uniqueLambdas) {
        List<List<double>> aDbl = List.generate(n, (i) => List.generate(n, (j) => matrix.get(i, j).toDouble()));
        List<double> vec = _inverseIteration(aDbl, lambda);
        
        Matrix vecMat = Matrix(n, 1);
        for(int i=0; i<n; i++) {
          vecMat.set(i, 0, _toFraction(vec[i]));
        }
        
        steps.add(SolutionStep("For λ = ${lambda.toStringAsFixed(2)}:\nSolve (A - λI)v = 0\nEigenvector:", vecMat));
      }
    }

    return steps;
  }

  // Symbolic step by step
  List<SolutionStep> getSymbolicStepByStep(SymbolicMatrix matrix) {
    List<SolutionStep> steps = [];
    int n = matrix.rows;

    if (n != 2 && n != 3) {
      steps.add(SolutionStep("Step-by-step solution is currently available only for 2x2 and 3x3 matrices."));
      return steps;
    }

    steps.add(SolutionStep("1. Find the Characteristic Polynomial\nThe characteristic polynomial is given by det(A - λI) = 0."));
    
    Expression poly = matrix.characteristicPolynomial('λ');
    steps.add(SolutionStep("Characteristic Equation:\n${poly.simplify()} = 0"));

    steps.add(SolutionStep("2. Eigenvalues & Eigenvectors\nFor symbolic matrices, numeric eigenvalues cannot be computed automatically.\nPlease solve the characteristic equation above for λ."));
    
    return steps;
  }

  List<SolutionStep> getDiagonalization(Matrix A) {
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Goal: Find P and D such that A = PDP⁻¹.\nD is the diagonal matrix of eigenvalues.\nP is the matrix where columns are corresponding eigenvectors."));
    
    try {
      List<EigenPair> pairs = getEigenPairs(A);
      
      if (pairs.length != A.rows) {
        steps.add(SolutionStep("Error: Found ${pairs.length} eigenpairs, but matrix is ${A.rows}x${A.rows}.\nMatrix might not be diagonalizable."));
        return steps;
      }
      
      Matrix D = Matrix(A.rows, A.cols);
      Matrix P = Matrix(A.rows, A.cols);
      
      for(int i=0; i<pairs.length; i++) {
        D.set(i, i, _toFraction(pairs[i].eigenvalue));
        for(int j=0; j<A.rows; j++) {
          P.set(j, i, _toFraction(pairs[i].eigenvector[j]));
        }
      }
      
      steps.add(SolutionStep("Matrix D (Eigenvalues on diagonal):", D));
      steps.add(SolutionStep("Matrix P (Eigenvectors as columns):", P));
      
      try {
        Matrix PInv = P.inverse();
        steps.add(SolutionStep("Matrix P⁻¹:", PInv));
        
        Matrix Res = P * D * PInv;
        steps.add(SolutionStep("Verification: P * D * P⁻¹ should equal A.", Res));
      } catch (e) {
        steps.add(SolutionStep("Warning: Verification skipped. Matrix P might be singular or calculations overflowed due to precision limits."));
      }
      
    } catch (e) {
      steps.add(SolutionStep("Error during diagonalization: $e"));
    }
    
    return steps;
  }

  List<double> _solveSystem(List<List<double>> A, List<double> b) {
    int n = A.length;
    // Clone to avoid modifying original
    List<List<double>> mat = List.generate(n, (i) => List.from(A[i]));
    List<double> rhs = List.from(b);

    // Gaussian elimination
    for (int i = 0; i < n; i++) {
      // Pivot
      int maxRow = i;
      for (int k = i + 1; k < n; k++) {
        if (mat[k][i].abs() > mat[maxRow][i].abs()) maxRow = k;
      }
      
      // Swap
      List<double> tempRow = mat[i]; mat[i] = mat[maxRow]; mat[maxRow] = tempRow;
      double tempB = rhs[i]; rhs[i] = rhs[maxRow]; rhs[maxRow] = tempB;

      if (mat[i][i].abs() < 1e-10) continue; // Singular or near singular

      for (int k = i + 1; k < n; k++) {
        double factor = mat[k][i] / mat[i][i];
        for (int j = i; j < n; j++) {
          mat[k][j] -= factor * mat[i][j];
        }
        rhs[k] -= factor * rhs[i];
      }
    }

    // Back substitution
    List<double> x = List.filled(n, 0.0);
    for (int i = n - 1; i >= 0; i--) {
      double sum = 0;
      for (int j = i + 1; j < n; j++) {
        sum += mat[i][j] * x[j];
      }
      if (mat[i][i].abs() > 1e-10) {
        x[i] = (rhs[i] - sum) / mat[i][i];
      }
    }
    return x;
  }
}
