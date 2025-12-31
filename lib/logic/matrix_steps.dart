import 'package:fraction/fraction.dart';
import 'matrix.dart';
import 'solution_step.dart';

extension MatrixSteps on Matrix {
  List<SolutionStep> determinantGaussianSteps() {
    if (rows != cols) throw Exception("Matrix must be square");
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Initial Matrix", clone()));

    Matrix temp = clone();
    Fraction det = Fraction(1);
    
    for (int j = 0; j < cols; j++) {
      int pivot = j;
      while (pivot < rows && temp.get(pivot, j) == Fraction(0)) {
        pivot++;
      }
      
      if (pivot == rows) {
        steps.add(SolutionStep("Column $j is all zeros. Determinant is 0.", temp.clone()));
        return steps;
      }
      
      if (pivot != j) {
        temp.swapRows(j, pivot);
        det *= Fraction(-1);
        steps.add(SolutionStep("Swap row ${j + 1} with row ${pivot + 1} (Sign changes)", temp.clone()));
      }
      
      for (int i = j + 1; i < rows; i++) {
        Fraction factor = temp.get(i, j) / temp.get(j, j);
        if (factor != Fraction(0)) {
          for (int k = j; k < cols; k++) {
            temp.set(i, k, temp.get(i, k) - temp.get(j, k) * factor);
          }
          steps.add(SolutionStep("R${i+1} = R${i+1} - ($factor) * R${j+1}", temp.clone()));
        }
      }
    }
    
    Fraction finalDet = Fraction(1);
    for(int i=0; i<rows; i++) {
      finalDet *= temp.get(i, i);
    }
    finalDet = finalDet * det;
    
    steps.add(SolutionStep("Upper Triangular Form Achieved", temp.clone()));
    
    Matrix res = Matrix(1, 1);
    res.set(0, 0, finalDet);
    steps.add(SolutionStep("Determinant = Product of Diagonal = $finalDet", res));
    
    return steps;
  }

  List<SolutionStep> determinantMontanteSteps() {
    if (rows != cols) throw Exception("Matrix must be square");
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Initial Matrix (Montante's Method)", clone()));

    Matrix temp = clone();
    Fraction pivotPrev = Fraction(1);
    
    for (int k = 0; k < rows; k++) {
      if (temp.get(k, k) == Fraction(0)) {
         int swapRow = -1;
         for(int i=k+1; i<rows; i++) {
           if (temp.get(i, k) != Fraction(0)) {
             swapRow = i;
             break;
           }
         }
         if (swapRow == -1) {
           steps.add(SolutionStep("Pivot is 0 and no swap possible. Det = 0", temp.clone()));
           return steps;
         }
         temp.swapRows(k, swapRow);
         steps.add(SolutionStep("Swap R${k+1} <-> R${swapRow+1} (Sign change tracked)", temp.clone()));
      }
      
      Fraction pivot = temp.get(k, k);
      steps.add(SolutionStep("Pivot at ($k, $k) is $pivot. Previous Pivot = $pivotPrev", temp.clone()));
      
      for (int i = k + 1; i < rows; i++) {
        for (int j = k + 1; j < cols; j++) {
          Fraction val = (temp.get(i, j) * pivot - temp.get(i, k) * temp.get(k, j)) / pivotPrev;
          temp.set(i, j, val);
        }
        temp.set(i, k, Fraction(0));
      }
      
      steps.add(SolutionStep("Iteration $k complete", temp.clone()));
      pivotPrev = pivot;
    }
    
    Fraction det = temp.get(rows - 1, cols - 1);
    Matrix res = Matrix(1, 1);
    res.set(0, 0, det);
    steps.add(SolutionStep("Final Determinant", res));
    return steps;
  }

  List<SolutionStep> determinantLaplaceSteps(int index, bool isRow) {
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Expand along ${isRow ? 'Row' : 'Column'} ${index + 1}", clone()));
    
    Fraction totalDet = Fraction(0);
    int n = rows;
    
    for (int i = 0; i < n; i++) {
      int r = isRow ? index : i;
      int c = isRow ? i : index;
      Fraction element = get(r, c);
      
      if (element != Fraction(0)) {
        int sign = ((r + c) % 2 == 0) ? 1 : -1;
        Matrix minor = getMinor(r, c);
        Fraction minorDet = minor.determinant();
        Fraction term = element * minorDet * Fraction(sign);
        totalDet += term;
        
        steps.add(SolutionStep(
          "Term ${i+1}: ${sign == 1 ? '+' : '-'}($element) * det(Minor at $r,$c) = $term",
          minor 
        ));
      }
    }
    
    Matrix res = Matrix(1, 1);
    res.set(0, 0, totalDet);
    steps.add(SolutionStep("Total Determinant = Sum of terms = $totalDet", res));
    
    return steps;
  }

  List<SolutionStep> additionSteps(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw Exception("Dimensions mismatch: $rows x $cols vs ${other.rows} x ${other.cols}");
    }
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Matrix A", clone()));
    steps.add(SolutionStep("Matrix B", other.clone()));

    Matrix result = Matrix(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        Fraction sum = get(i, j) + other.get(i, j);
        result.set(i, j, sum);
      }
    }
    steps.add(SolutionStep("Result = A + B (Element-wise addition)", result));
    return steps;
  }

  List<SolutionStep> subtractionSteps(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw Exception("Dimensions mismatch");
    }
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Matrix A", clone()));
    steps.add(SolutionStep("Matrix B", other.clone()));

    Matrix result = Matrix(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        Fraction diff = get(i, j) - other.get(i, j);
        result.set(i, j, diff);
      }
    }
    steps.add(SolutionStep("Result = A - B (Element-wise subtraction)", result));
    return steps;
  }

  List<SolutionStep> multiplicationSteps(Matrix other) {
    if (cols != other.rows) {
      throw Exception("Invalid dimensions: $rows x $cols vs ${other.rows} x ${other.cols}");
    }
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Matrix A ($rows x $cols)", clone()));
    steps.add(SolutionStep("Matrix B (${other.rows} x ${other.cols})", other.clone()));

    Matrix result = Matrix(rows, other.cols);
    
    StringBuffer explanation = StringBuffer();
    explanation.writeln("Multiplying rows of A by columns of B:");
    
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < other.cols; j++) {
        Fraction sum = Fraction(0);
        List<String> terms = [];
        for (int k = 0; k < cols; k++) {
          Fraction a = get(i, k);
          Fraction b = other.get(k, j);
          sum += a * b;
          terms.add("($a * $b)");
        }
        result.set(i, j, sum);
        
        if (i == 0 && j == 0) {
           explanation.writeln("C[1,1] = ${terms.join(' + ')} = $sum");
        }
      }
    }
    if (rows * other.cols > 1) {
       explanation.writeln("... and so on for all elements.");
    }
    
    steps.add(SolutionStep(explanation.toString(), result));
    return steps;
  }

  List<SolutionStep> scalarMultiplicationSteps(Fraction k) {
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Matrix A", clone()));
    steps.add(SolutionStep("Scalar k = $k", null)); 

    Matrix result = Matrix(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        result.set(i, j, get(i, j) * k);
      }
    }
    steps.add(SolutionStep("Result = A * k (Multiply every element by $k)", result));
    return steps;
  }

  List<SolutionStep> transposeSteps() {
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Original Matrix A", clone()));
    Matrix res = transpose();
    steps.add(SolutionStep("Transposed Matrix A^T (Swap rows and columns)", res));
    return steps;
  }

  List<SolutionStep> inverseSteps() {
    if (rows != cols) throw Exception("Matrix must be square");
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Initial Matrix A", clone()));

    Fraction det = determinant();
    if (det == Fraction(0)) {
      steps.add(SolutionStep("Determinant is 0. Matrix is Singular and has no inverse.", null));
      return steps;
    }

    Matrix augmented = Matrix(rows, cols * 2);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        augmented.set(i, j, get(i, j));
      }
      augmented.set(i, cols + i, Fraction(1));
    }
    steps.add(SolutionStep("Augmented Matrix [A | I]", augmented.clone()));

    for (int j = 0; j < cols; j++) {
      int pivot = j;
      while (pivot < rows && augmented.get(pivot, j) == Fraction(0)) {
        pivot++;
      }
      
      if (pivot != j) {
        augmented.swapRows(j, pivot);
        steps.add(SolutionStep("Swap R${j+1} <-> R${pivot+1}", augmented.clone()));
      }
      
      Fraction div = augmented.get(j, j);
      if (div != Fraction(1)) {
        augmented.multiplyRow(j, Fraction(1) / div);
        steps.add(SolutionStep("Normalize R${j+1} (Divide by $div)", augmented.clone()));
      }
      
      for (int i = 0; i < rows; i++) {
        if (i != j) {
          Fraction factor = augmented.get(i, j);
          if (factor != Fraction(0)) {
            augmented.addRow(i, j, factor * Fraction(-1));
            steps.add(SolutionStep("R${i+1} = R${i+1} - ($factor) * R${j+1}", augmented.clone()));
          }
        }
      }
    }

    Matrix inv = Matrix(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        inv.set(i, j, augmented.get(i, cols + j));
      }
    }
    steps.add(SolutionStep("Inverse Matrix A^-1 (Right half of augmented matrix)", inv));
    return steps;
  }

  List<SolutionStep> rankSteps() {
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Initial Matrix", clone()));
    
    Matrix temp = clone();
    int pivotRow = 0;
    
    for (int j = 0; j < cols && pivotRow < rows; j++) {
      int i = pivotRow;
      while (i < rows && temp.get(i, j) == Fraction(0)) {
        i++;
      }
      
      if (i < rows) {
        if (i != pivotRow) {
          temp.swapRows(pivotRow, i);
          steps.add(SolutionStep("Swap R${pivotRow+1} <-> R${i+1}", temp.clone()));
        }
        
        for (int k = pivotRow + 1; k < rows; k++) {
          Fraction factor = temp.get(k, j) / temp.get(pivotRow, j);
          if (factor != Fraction(0)) {
             for (int l = j; l < cols; l++) {
               temp.set(k, l, temp.get(k, l) - temp.get(pivotRow, l) * factor);
             }
             steps.add(SolutionStep("R${k+1} = R${k+1} - ($factor) * R${pivotRow+1}", temp.clone()));
          }
        }
        pivotRow++;
      }
    }
    
    steps.add(SolutionStep("Row Echelon Form Reached", temp.clone()));
    
    int rank = 0;
    for(int i=0; i<rows; i++) {
      bool nonZero = false;
      for(int j=0; j<cols; j++) {
        if (temp.get(i, j) != Fraction(0)) {
          nonZero = true;
          break;
        }
      }
      if (nonZero) rank++;
    }
    
    steps.add(SolutionStep("Rank = Number of non-zero rows = $rank", null));
    return steps;
  }

  List<SolutionStep> powerSteps(int exponent) {
    if (rows != cols) throw Exception("Matrix must be square");
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Initial Matrix A", clone()));
    steps.add(SolutionStep("Exponent n = $exponent", null));

    if (exponent == 0) {
      Matrix identity = Matrix(rows, cols);
      for (int i = 0; i < rows; i++) {
        identity.set(i, i, Fraction(1));
      }
      steps.add(SolutionStep("A^0 = Identity Matrix", identity));
      return steps;
    }
    
    if (exponent < 0) {
       steps.add(SolutionStep("Exponent is negative. Calculating inverse first.", null));
       // We can't easily chain steps here without refactoring.
       // Let's just calculate inverse and then power.
       try {
         Matrix inv = inverse();
         steps.add(SolutionStep("Inverse A^-1", inv));
         // Now power of inverse
         Matrix res = inv.pow(-exponent);
         steps.add(SolutionStep("Result = (A^-1)^${-exponent}", res));
         return steps;
       } catch (e) {
         steps.add(SolutionStep("Matrix is singular, cannot compute negative power.", null));
         return steps;
       }
    }

    Matrix result = clone();
    for (int i = 1; i < exponent; i++) {
      result = result * this;
      steps.add(SolutionStep("Iteration $i: A^${i+1} = A^$i * A", result.clone()));
    }
    return steps;
  }
}
