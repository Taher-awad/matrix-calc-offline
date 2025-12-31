import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import '../../logic/matrix.dart';
import '../../logic/solvers.dart';
import '../../logic/solution_step.dart';
import '../../logic/history_service.dart';
import '../solution_screen.dart';
import '../common/status_card.dart';

class SystemSolverTab extends StatefulWidget {
  const SystemSolverTab({super.key});

  @override
  State<SystemSolverTab> createState() => SystemSolverTabState();
}

class SystemSolverTabState extends State<SystemSolverTab> {
  int _rows = 3;
  int _cols = 3;
  final List<List<TextEditingController>> _controllers = [];
  final List<TextEditingController> _constantsControllers = [];
  
  String _errorText = "";
  String _selectedMethod = "Gaussian Elimination";
  final List<String> _methods = [
    "Gaussian Elimination",
    "Gauss-Jordan Elimination",
    "Cramer's Rule",
    "Inverse Matrix Method",
    "Linear Least Squares"
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Clear existing
    for (var row in _controllers) {
      for (var c in row) {
        c.dispose();
      }
    }
    for (var c in _constantsControllers) {
      c.dispose();
    }
    _controllers.clear();
    _constantsControllers.clear();

    // Create new
    for (int i = 0; i < _rows; i++) {
      List<TextEditingController> row = [];
      for (int j = 0; j < _cols; j++) {
        row.add(TextEditingController());
      }
      _controllers.add(row);
      _constantsControllers.add(TextEditingController());
    }
  }

  void _updateRows(int delta) {
    setState(() {
      int newRows = _rows + delta;
      if (newRows >= 2 && newRows <= 6) {
        _rows = newRows;
        _initializeControllers();
      }
    });
  }

  void _updateCols(int delta) {
    setState(() {
      int newCols = _cols + delta;
      if (newCols >= 2 && newCols <= 6) {
        _cols = newCols;
        _initializeControllers();
      }
    });
  }

  void _solve() {
    setState(() => _errorText = "");
    try {
      // Parse input
      List<List<Fraction>> matrixData = [];
      List<Fraction> constantsData = [];

      for (int i = 0; i < _rows; i++) {
        List<Fraction> row = [];
        for (int j = 0; j < _cols; j++) {
          String text = _controllers[i][j].text;
          row.add(Matrix.safeParseFraction(text));
        }
        matrixData.add(row);
        
        String constText = _constantsControllers[i].text;
        constantsData.add(Matrix.safeParseFraction(constText));
      }

      Matrix matrix = Matrix.fromData(matrixData);
      LinearSolver solver;
      
      if (_rows != _cols) {
        if (_selectedMethod == "Cramer's Rule" || _selectedMethod == "Inverse Matrix Method") {
          throw Exception("$_selectedMethod requires a square matrix (Rows must equal Columns).");
        }
      }
      
      switch (_selectedMethod) {
        case "Cramer's Rule":
          solver = CramerSolver();
          break;
        case "Inverse Matrix Method":
          solver = InverseMatrixSolver();
          break;
        case "Gauss-Jordan Elimination":
          solver = GaussJordanSolver();
          break;
        case "Linear Least Squares":
          solver = LeastSquaresSolver();
          break;
        case "Gaussian Elimination":
        default:
          solver = GaussianSolver();
      }

      List<SolutionStep> steps = solver.solve(matrix, constantsData);

      // Log to history
      // System solver result is a vector (x, y, z...).
      // We can store it as a column matrix.
      // Usually the last step has the result.
      // Let's inspect the last step.
      if (steps.isNotEmpty && steps.last.matrixState != null) {
        HistoryService().add(steps.last.matrixState!, "System Solution");
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolutionScreen(steps: steps),
        ),
      );
    } catch (e) {
      setState(() {
        _errorText = "Error: $e";
      });
    }
  }

  void _clear() {
    for (var row in _controllers) {
      for (var c in row) {
        c.clear();
      }
    }
    for (var c in _constantsControllers) {
      c.clear();
    }
  }

  void setSystem(Matrix coeffs, Matrix constants) {
    setState(() {
      _rows = coeffs.rows;
      _cols = coeffs.cols;
      if (_rows < 2) _rows = 2;
      if (_rows > 6) _rows = 6;
      if (_cols < 2) _cols = 2;
      if (_cols > 6) _cols = 6;
      
      _initializeControllers();

      for(int i=0; i<_rows && i<coeffs.rows; i++) {
        for(int j=0; j<_cols && j<coeffs.cols; j++) {
          _controllers[i][j].text = Matrix.formatValueForInput(coeffs.get(i, j));
        }
        if (i < constants.rows) {
          _constantsControllers[i].text = Matrix.formatValueForInput(constants.get(i, 0));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_errorText.isNotEmpty)
            StatusCard(
              text: _errorText,
              onDismiss: () => setState(() => _errorText = ""),
            ),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text("Rows"),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _updateRows(-1),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_rows', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        onPressed: () => _updateRows(1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  const Text("Cols"),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _updateCols(-1),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_cols', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        onPressed: () => _updateCols(1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Method Selector
          // Method Selector
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedMethod,
            items: _methods.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedMethod = newValue!;
              });
            },
          ),

          const SizedBox(height: 20),
          
          // Matrix Input
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coefficients Matrix
              Expanded(
                flex: 3,
                child: Column(
                  children: List.generate(_rows, (i) {
                    return Row(
                      children: List.generate(_cols, (j) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextField(
                              controller: _controllers[i][j],
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
              
              // Equals sign
              SizedBox(
                width: 30,
                height: _rows * 50.0,
                child: const Center(child: Text('=', style: TextStyle(fontSize: 24))),
              ),

              // Constants Vector
              Expanded(
                flex: 1,
                child: Column(
                  children: List.generate(_rows, (i) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextField(
                        controller: _constantsControllers[i],
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
              ),
              ElevatedButton.icon(
                onPressed: _solve,
                icon: const Icon(Icons.calculate),
                label: const Text('Solve'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
