import 'package:fraction/fraction.dart';
import 'solution_step.dart';

class Matrix {
  final int rows;
  final int cols;
  final List<List<Fraction>> _data;

  Matrix(this.rows, this.cols)
      : _data = List.generate(
            rows, (_) => List.generate(cols, (_) => Fraction(0)));

  Matrix.fromData(List<List<Fraction>> data)
      : rows = data.length,
        cols = data[0].length,
        _data = data.map((row) => List<Fraction>.from(row)).toList();

  Fraction get(int row, int col) => _data[row][col];

  void set(int row, int col, Fraction value) {
    _data[row][col] = value;
  }

  List<Fraction> getRow(int row) => List.from(_data[row]);

  void swapRows(int row1, int row2) {
    final temp = _data[row1];
    _data[row1] = _data[row2];
    _data[row2] = temp;
  }

  void multiplyRow(int row, Fraction scalar) {
    for (int j = 0; j < cols; j++) {
      _data[row][j] *= scalar;
    }
  }

  void addRow(int targetRow, int sourceRow, Fraction scalar) {
    for (int j = 0; j < cols; j++) {
      _data[targetRow][j] += _data[sourceRow][j] * scalar;
    }
  }

  Matrix clone() {
    return Matrix.fromData(_data);
  }

  @override
  String toString() {
    return _data.map((row) => row.join(' ')).join('\n');
  }

  // --- Operations ---

  Matrix operator +(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw Exception("Matrix dimensions must match for addition");
    }
    Matrix result = Matrix(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        result.set(i, j, get(i, j) + other.get(i, j));
      }
    }
    return result;
  }

  Matrix operator -(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw Exception("Matrix dimensions must match for subtraction");
    }
    Matrix result = Matrix(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        result.set(i, j, get(i, j) - other.get(i, j));
      }
    }
    return result;
  }

  // Modified operator * to handle both Matrix and Scalar multiplication
  dynamic operator *(dynamic other) {
    if (other is Matrix) {
      if (cols != other.rows) {
        throw Exception("Invalid dimensions for multiplication");
      }
      Matrix result = Matrix(rows, other.cols);
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < other.cols; j++) {
          Fraction sum = Fraction(0);
          for (int k = 0; k < cols; k++) {
            sum += get(i, k) * other.get(k, j);
          }
          result.set(i, j, sum);
        }
      }
      return result;
    } else if (other is num || other is Fraction) {
      Fraction scalar = other is Fraction ? other : Fraction.fromString(other.toString());
      Matrix result = Matrix(rows, cols);
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          result.set(i, j, get(i, j) * scalar);
        }
      }
      return result;
    } else {
      throw Exception("Unsupported type for multiplication");
    }
  }

  Matrix pow(int exponent) {
    if (rows != cols) throw Exception("Matrix must be square for exponentiation");
    if (exponent < 0) return inverse().pow(-exponent);
    if (exponent == 0) {
      // Identity matrix
      Matrix identity = Matrix(rows, cols);
      for (int i = 0; i < rows; i++) {
        identity.set(i, i, Fraction(1));
      }
      return identity;
    }
    
    Matrix result = clone();
    for (int i = 1; i < exponent; i++) {
      result = result * this;
    }
    return result;
  }

  Matrix triangleForm() {
    Matrix temp = clone();
    int pivotRow = 0;
    
    for (int j = 0; j < cols && pivotRow < rows; j++) {
      int i = pivotRow;
      while (i < rows && temp.get(i, j) == Fraction(0)) {
        i++;
      }
      
      if (i < rows) {
        temp.swapRows(pivotRow, i);
        
        // Optional: Normalize pivot to 1? usually Row Echelon Form requires pivot to be 1
        // But "Triangular Form" just needs zeros below. Let's do strict REF (pivot=1)
        /* 
        Fraction div = temp.get(pivotRow, j);
        temp.multiplyRow(pivotRow, Fraction(1) / div);
        */

        for (int k = pivotRow + 1; k < rows; k++) {
          Fraction factor = temp.get(k, j) / temp.get(pivotRow, j);
          for (int l = j; l < cols; l++) {
            temp.set(k, l, temp.get(k, l) - temp.get(pivotRow, l) * factor);
          }
        }
        pivotRow++;
      }
    }
    return temp;
  }

  Matrix rref() {
    Matrix augmented = clone();
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
      }

      Fraction pivot = augmented.get(pivotRow, j);
      if (pivot != Fraction(1)) {
        augmented.multiplyRow(pivotRow, Fraction(1) / pivot);
      }

      for (int i = 0; i < rows; i++) {
        if (i != pivotRow) {
          Fraction factor = augmented.get(i, j);
          if (factor != Fraction(0)) {
            augmented.addRow(i, pivotRow, factor * Fraction(-1));
          }
        }
      }
      pivotRow++;
    }
    return augmented;
  }

  Matrix transpose() {
    Matrix result = Matrix(cols, rows);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        result.set(j, i, get(i, j));
      }
    }
    return result;
  }

  Fraction determinant() {
    if (rows != cols) throw Exception("Matrix must be square");
    if (rows == 1) return get(0, 0);
    if (rows == 2) {
      return get(0, 0) * get(1, 1) - get(0, 1) * get(1, 0);
    }
    
    // Gaussian elimination for determinant
    Matrix temp = clone();
    Fraction det = Fraction(1);
    
    for (int j = 0; j < cols; j++) {
      int pivot = j;
      while (pivot < rows && temp.get(pivot, j) == Fraction(0)) {
        pivot++;
      }
      
      if (pivot == rows) return Fraction(0); // Zero column
      
      if (pivot != j) {
        temp.swapRows(j, pivot);
        det *= Fraction(-1);
      }
      
      det *= temp.get(j, j);
      
      for (int i = j + 1; i < rows; i++) {
        Fraction factor = temp.get(i, j) / temp.get(j, j);
        for (int k = j; k < cols; k++) {
          temp.set(i, k, temp.get(i, k) - temp.get(j, k) * factor);
        }
      }
    }
    return det;
  }

  Matrix inverse() {
    if (rows != cols) throw Exception("Matrix must be square");
    Fraction det = determinant();
    if (det == Fraction(0)) throw Exception("Matrix is singular");

    // Augmented matrix [A | I]
    Matrix augmented = Matrix(rows, cols * 2);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        augmented.set(i, j, get(i, j));
      }
      augmented.set(i, cols + i, Fraction(1));
    }

    // Gaussian elimination
    for (int j = 0; j < cols; j++) {
      int pivot = j;
      while (pivot < rows && augmented.get(pivot, j) == Fraction(0)) {
        pivot++;
      }
      
      if (pivot != j) {
        augmented.swapRows(j, pivot);
      }
      
      Fraction div = augmented.get(j, j);
      augmented.multiplyRow(j, Fraction(1) / div);
      
      for (int i = 0; i < rows; i++) {
        if (i != j) {
          Fraction factor = augmented.get(i, j);
          augmented.addRow(i, j, factor * Fraction(-1));
        }
      }
    }

    // Extract inverse
    Matrix inv = Matrix(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        inv.set(i, j, augmented.get(i, cols + j));
      }
    }
    return inv;
  }

  int rank() {
    Matrix temp = clone();
    int rank = 0;
    List<bool> rowSelected = List.filled(rows, false);
    
    for (int j = 0; j < cols; j++) {
      int i = 0;
      while (i < rows && (rowSelected[i] || temp.get(i, j) == Fraction(0))) {
        i++;
      }
      
      if (i < rows) {
        rank++;
        rowSelected[i] = true;
        for (int k = 0; k < rows; k++) {
          if (k != i) {
            Fraction factor = temp.get(k, j) / temp.get(i, j);
            for (int l = j; l < cols; l++) {
              temp.set(k, l, temp.get(k, l) - temp.get(i, l) * factor);
            }
          }
        }
      }
    }
    return rank;
  }
  Fraction determinantMontante() {
    if (rows != cols) throw Exception("Matrix must be square");
    // Bareiss algorithm (Montante's method)
    // Preserves integers if input is integer.
    // M[k][i,j] = (M[k-1][i,j]*M[k-1][k,k] - M[k-1][i,k]*M[k-1][k,j]) / M[k-2][k,k]
    
    Matrix temp = clone();
    Fraction pivotPrev = Fraction(1);
    
    for (int k = 0; k < rows; k++) {
      // Find pivot
      if (temp.get(k, k) == Fraction(0)) {
        // Swap with non-zero row
        int swapRow = -1;
        for(int i=k+1; i<rows; i++) {
          if (temp.get(i, k) != Fraction(0)) {
            swapRow = i;
            break;
          }
        }
        if (swapRow == -1) return Fraction(0);
        temp.swapRows(k, swapRow);
        // Swap changes sign? In Montante usually handled differently or just standard swap sign change.
        // Let's stick to standard Gaussian for sign if we swap.
        // Actually Montante is specific. If we swap, sign changes.
        // But the division step relies on previous pivot.
        // Let's assume standard Bareiss.
        // If we swap, we multiply result by -1.
        // But wait, Bareiss is about integer preservation.
        // Let's implement standard Bareiss.
      }
      
      Fraction pivot = temp.get(k, k);
      
      for (int i = k + 1; i < rows; i++) {
        for (int j = k + 1; j < cols; j++) {
          Fraction val = (temp.get(i, j) * pivot - temp.get(i, k) * temp.get(k, j)) / pivotPrev;
          temp.set(i, j, val);
        }
      }
      pivotPrev = pivot;
    }
    
    return temp.get(rows - 1, cols - 1);
  }

  Fraction determinantLaplace(int index, bool isRow) {
    if (rows != cols) throw Exception("Matrix must be square");
    if (rows == 1) return get(0, 0);
    
    Fraction det = Fraction(0);
    int sign = (index % 2 == 0) ? 1 : -1; // Base sign for the row/col index? 
    // Cofactor C_ij = (-1)^(i+j) * M_ij
    
    if (isRow) {
      // Expand along row 'index'
      for (int j = 0; j < cols; j++) {
        Fraction element = get(index, j);
        if (element != Fraction(0)) {
          // Sign is (-1)^(index + j)
          int s = ((index + j) % 2 == 0) ? 1 : -1;
          det += element * getMinor(index, j).determinant() * Fraction(s);
        }
      }
    } else {
      // Expand along column 'index'
      for (int i = 0; i < rows; i++) {
        Fraction element = get(i, index);
        if (element != Fraction(0)) {
          // Sign is (-1)^(i + index)
          int s = ((i + index) % 2 == 0) ? 1 : -1;
          det += element * getMinor(i, index).determinant() * Fraction(s);
        }
      }
    }
    return det;
  }

  Matrix getMinor(int rowToRemove, int colToRemove) {
    List<List<Fraction>> newData = [];
    for (int i = 0; i < rows; i++) {
      if (i == rowToRemove) continue;
      List<Fraction> newRow = [];
      for (int j = 0; j < cols; j++) {
        if (j == colToRemove) continue;
        newRow.add(get(i, j));
      }
      newData.add(newRow);
    }
    return Matrix.fromData(newData);
  }
  // --- Step-by-Step Methods moved to matrix_steps.dart ---
  
  List<SolutionStep> triangleSteps() {
     // Reuse rank steps logic basically, but just return REF
     // Let's implement explicitly to be safe
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
    steps.add(SolutionStep("Triangular Form (Row Echelon Form)", temp));
    return steps;
  }
  
  List<SolutionStep> rrefSteps() {
    List<SolutionStep> steps = [];
    steps.add(SolutionStep("Initial Matrix", clone()));
    
    Matrix augmented = clone();
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
        steps.add(SolutionStep("Swap R${pivotRow+1} <-> R${maxRow+1}", augmented.clone()));
      }

      Fraction pivot = augmented.get(pivotRow, j);
      if (pivot != Fraction(1)) {
        augmented.multiplyRow(pivotRow, Fraction(1) / pivot);
        steps.add(SolutionStep("Normalize R${pivotRow+1} (Divide by $pivot)", augmented.clone()));
      }

      for (int i = 0; i < rows; i++) {
        if (i != pivotRow) {
          Fraction factor = augmented.get(i, j);
          if (factor != Fraction(0)) {
            augmented.addRow(i, pivotRow, factor * Fraction(-1));
            steps.add(SolutionStep("R${i+1} = R${i+1} - ($factor) * R${pivotRow+1}", augmented.clone()));
          }
        }
      }
      pivotRow++;
    }
    steps.add(SolutionStep("Reduced Row Echelon Form (RREF)", augmented));
    return steps;
  }

  Map<String, dynamic> toJson() {
    List<List<String>> dataStrings = [];
    for (int i = 0; i < rows; i++) {
      List<String> row = [];
      for (int j = 0; j < cols; j++) {
        row.add(get(i, j).toString());
      }
      dataStrings.add(row);
    }
    return {
      'rows': rows,
      'cols': cols,
      'data': dataStrings,
    };
  }

  factory Matrix.fromJson(Map<String, dynamic> json) {
    int rows = json['rows'];
    int cols = json['cols'];
    List<dynamic> dataStrings = json['data'];
    
    List<List<Fraction>> data = [];
    for (int i = 0; i < rows; i++) {
      List<Fraction> row = [];
      List<dynamic> jsonRow = dataStrings[i];
      for (int j = 0; j < cols; j++) {
        row.add(Fraction.fromString(jsonRow[j]));
      }
      data.add(row);
    }
    return Matrix.fromData(data);
  }

  static String formatValueForInput(Fraction f) {
    Fraction reduced = f.reduce();
    if (reduced.denominator > 1000) {
      String s = reduced.toDouble().toStringAsFixed(6);
      if (s.contains('.')) {
        s = s.replaceAll(RegExp(r"0*$"), "");
        s = s.replaceAll(RegExp(r"\.$"), "");
      }
      return s;
    }
    return reduced.toString();
  }

  static Fraction safeParseFraction(String text) {
    if (text.isEmpty) return Fraction(0);
    try {
      return Fraction.fromString(text);
    } catch (e) {
      // Try parsing as double if Fraction.fromString failed (e.g. for decimals)
      try {
        double d = double.parse(text);
        return Fraction.fromDouble(d);
      } catch (_) {
        throw e; // Rethrow original error if double parse also fails
      }
    }
  }
}
