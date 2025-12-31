import 'package:math_expressions/math_expressions.dart';

class SymbolicMatrix {
  final int rows;
  final int cols;
  final List<List<Expression>> _data;

  SymbolicMatrix(this.rows, this.cols)
      : _data = List.generate(
            rows, (_) => List.generate(cols, (_) => Number(0)));

  SymbolicMatrix.fromData(List<List<Expression>> data)
      : rows = data.length,
        cols = data[0].length,
        _data = data.map((row) => List<Expression>.from(row)).toList();

  // Factory to create from string inputs (parsing "1x", "2", etc.)
  factory SymbolicMatrix.fromStrings(List<List<String>> strings) {
    Parser p = Parser();
    List<List<Expression>> data = [];
    for (var row in strings) {
      List<Expression> exprRow = [];
      for (var s in row) {
        if (s.isEmpty) {
          exprRow.add(Number(0));
        } else {
          try {
            // Handle implicit multiplication like "2x" -> "2*x"
            // Simple regex to find digit followed immediately by letter
            String processed = s.replaceAllMapped(
                RegExp(r'(\d)([a-zA-Z])'), (match) => '${match.group(1)}*${match.group(2)}');
            exprRow.add(p.parse(processed));
          } catch (e) {
            // Fallback or error
            print("Error parsing '$s': $e");
            exprRow.add(Number(0));
          }
        }
      }
      data.add(exprRow);
    }
    return SymbolicMatrix.fromData(data);
  }

  Expression get(int row, int col) => _data[row][col];

  void set(int row, int col, Expression value) {
    _data[row][col] = value;
  }

  // Symbolic Determinant (Laplace Expansion for generality, or specific for 2x2/3x3)
  Expression determinant() {
    if (rows != cols) throw Exception("Matrix must be square");
    if (rows == 1) return get(0, 0);
    if (rows == 2) {
      // ad - bc
      return (get(0, 0) * get(1, 1)) - (get(0, 1) * get(1, 0));
    }
    if (rows == 3) {
      // Sarrus Rule or Laplace
      // a(ei - fh) - b(di - fg) + c(dh - eg)
      var a = get(0, 0); var b = get(0, 1); var c = get(0, 2);
      var d = get(1, 0); var e = get(1, 1); var f = get(1, 2);
      var g = get(2, 0); var h = get(2, 1); var i = get(2, 2);

      return (a * ((e * i) - (f * h))) -
             (b * ((d * i) - (f * g))) +
             (c * ((d * h) - (e * g)));
    }
    
    // For larger matrices, recursive Laplace expansion
    return _laplaceExpansion(this);
  }

  Expression _laplaceExpansion(SymbolicMatrix m) {
    if (m.rows == 1) return m.get(0, 0);
    Expression det = Number(0);
    for (int j = 0; j < m.cols; j++) {
      Expression element = m.get(0, j);
      if (element is Number && element.value == 0) continue; // Optimization

      SymbolicMatrix sub = m._subMatrix(0, j);
      Expression subDet = _laplaceExpansion(sub);
      
      if (j % 2 == 0) {
        det = det + (element * subDet);
      } else {
        det = det - (element * subDet);
      }
    }
    return det;
  }

  SymbolicMatrix _subMatrix(int excludeRow, int excludeCol) {
    List<List<Expression>> newData = [];
    for (int i = 0; i < rows; i++) {
      if (i == excludeRow) continue;
      List<Expression> newRow = [];
      for (int j = 0; j < cols; j++) {
        if (j == excludeCol) continue;
        newRow.add(get(i, j));
      }
      newData.add(newRow);
    }
    return SymbolicMatrix.fromData(newData);
  }

  // Characteristic Polynomial: det(A - lambda*I)
  // We return the Expression in terms of variable 'lambda' (or 'x' if preferred)
  Expression characteristicPolynomial(String lambdaVarName) {
    if (rows != cols) throw Exception("Matrix must be square");
    
    // Create (A - lambda*I)
    List<List<Expression>> polyData = [];
    Variable lambda = Variable(lambdaVarName);

    for (int i = 0; i < rows; i++) {
      List<Expression> row = [];
      for (int j = 0; j < cols; j++) {
        Expression val = get(i, j);
        if (i == j) {
          // Diagonal: val - lambda
          row.add(val - lambda);
        } else {
          row.add(val);
        }
      }
      polyData.add(row);
    }
    
    SymbolicMatrix polyMatrix = SymbolicMatrix.fromData(polyData);
    Expression det = polyMatrix.determinant();
    
    // Simplify if possible
    return det.simplify();
  }
  
  @override
  String toString() {
    return _data.map((row) => row.map((e) => e.toString()).join('\t')).join('\n');
  }
}
