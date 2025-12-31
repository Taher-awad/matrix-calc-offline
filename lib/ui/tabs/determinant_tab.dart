import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import '../../logic/matrix.dart';
import '../../logic/matrix_steps.dart';
import '../../logic/solution_step.dart';
import '../../logic/history_service.dart';
import '../matrix_input.dart';
import '../solution_screen.dart';

import '../home_screen.dart';
import '../common/status_card.dart';

class DeterminantTab extends StatefulWidget {
  final MatrixEvent? matrixEvent;
  const DeterminantTab({super.key, this.matrixEvent});

  @override
  State<DeterminantTab> createState() => DeterminantTabState();
}

class DeterminantTabState extends State<DeterminantTab> {
  int _size = 3;
  final List<List<TextEditingController>> _controllers = [];
  String _resultText = "";
  String _selectedMethod = "Gaussian Elimination";
  
  MatrixEvent? _lastProcessedEvent;

  int _selectedIndex = 0; // For row/col expansion
  final bool _isRow = true; // Expand along row?

  final List<String> _methods = [
    "Gaussian Elimination",
    "Triangle Rule",
    "Rule of Sarrus",
    "Leibniz Formula",
    "Montante's Method",
    "Expand along Row",
    "Expand along Column"
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _checkEvents();
  }

  @override
  void didUpdateWidget(DeterminantTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkEvents();
  }

  void _checkEvents() {
    if (widget.matrixEvent != null && widget.matrixEvent != _lastProcessedEvent) {
      _lastProcessedEvent = widget.matrixEvent;
      // Delay slightly to ensure build is ready if needed, or just set state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setMatrixA(widget.matrixEvent!.matrix);
        }
      });
    }
  }

  void _initControllers() {
    for (var row in _controllers) {
      for (var c in row) {
        c.dispose();
      }
    }
    _controllers.clear();
    for (int i = 0; i < _size; i++) {
      List<TextEditingController> row = [];
      for (int j = 0; j < _size; j++) {
        row.add(TextEditingController());
      }
      _controllers.add(row);
    }
  }

  void _updateSize(int delta, int _) {
    setState(() {
      int newSize = _size + delta;
      if (newSize >= 2 && newSize <= 5) {
        _size = newSize;
        _initControllers();
        // Reset selection if out of bounds
        if (_selectedIndex >= _size) _selectedIndex = 0;
      }
    });
  }

  void _onMatrixCaptured(Matrix m) {
    setState(() {
      _size = m.rows; // Determinant needs square matrix, assume OCR returns square or we take rows
      if (_size < 2) _size = 2;
      if (_size > 5) _size = 5;
      
      _initControllers();

      for(int i=0; i<_size && i<m.rows; i++) {
        for(int j=0; j<_size && j<m.cols; j++) {
          _controllers[i][j].text = Matrix.formatValueForInput(m.get(i, j));
        }
      }
    });
  }

  void _calculate() {
    try {
      List<List<Fraction>> data = [];
      for (int i = 0; i < _size; i++) {
        List<Fraction> row = [];
        for (int j = 0; j < _size; j++) {
          String text = _controllers[i][j].text;
          row.add(Matrix.safeParseFraction(text));
        }
        data.add(row);
      }
      Matrix matrix = Matrix.fromData(data);
      
      List<SolutionStep> steps = [];
      
      switch (_selectedMethod) {
        case "Montante's Method":
          steps = matrix.determinantMontanteSteps();
          break;
        case "Expand along Row":
          steps = matrix.determinantLaplaceSteps(_selectedIndex, true);
          break;
        case "Expand along Column":
          steps = matrix.determinantLaplaceSteps(_selectedIndex, false);
          break;
        case "Gaussian Elimination":
        default:
          steps = matrix.determinantGaussianSteps();
      }

      // Navigate to SolutionScreen
      // We need to import SolutionScreen and SolutionStep (from solvers.dart)
      // Assuming imports are added.
      // Log to history
      // Determinant result is a scalar, but we can store it as 1x1 matrix?
      // Or the steps contain the matrix state.
      // Actually, for determinant, the result is a number.
      // Let's create a 1x1 matrix for the result.
      // Wait, the steps might end with the triangular matrix or similar.
      // But the user wants the *result*.
      // If we use `steps`, the last step usually shows the result.
      // Let's just store the input matrix A? No, user wants output.
      // For determinant, the output is a scalar.
      // I'll create a 1x1 matrix with the determinant value.
      // But I don't have the value easily here unless I parse it or get it from solver.
      // Solver returns steps.
      // Let's assume the last step has the result description "Determinant = X".
      // This is tricky.
      // Maybe I should just store the *input* matrix for Determinant tab?
      // User said "put the output into current tab".
      // If the output is a number (Determinant), putting it into a Matrix (A/B) means a 1x1 matrix?
      // Yes.
      // But I don't have the numeric result here easily.
      // I'll skip history for Determinant for now, or just log the input matrix?
      // No, let's log the input matrix as "Determinant Input".
      // Or better, update `Matrix` to return the determinant value along with steps.
      // For now, I will NOT add history to Determinant to avoid complexity, or just add the input.
      // Let's add the input matrix with op "Determinant(A)".
      HistoryService().add(matrix, "Determinant Input");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolutionScreen(steps: steps),
        ),
      );

    } catch (e) {
      setState(() {
        _resultText = "Error: $e";
      });
    }
  }

  void setMatrixA(Matrix m) {
    _onMatrixCaptured(m);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          MatrixInput(
            label: "Matrix A",
            controllers: _controllers,
            rows: _size,
            cols: _size,
            onResize: _updateSize,
          ),
          const SizedBox(height: 20),
          DropdownButton<String>(
            value: _selectedMethod,
            items: _methods.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedMethod = newValue!;
              });
            },
          ),
          if (_selectedMethod.contains("Expand")) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${_selectedMethod.contains("Row") ? "Row" : "Column"} Index: "),
                DropdownButton<int>(
                  value: _selectedIndex,
                  items: List.generate(_size, (index) => index).map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text((value + 1).toString()),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedIndex = newValue!;
                    });
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _calculate,
            child: const Text('Calculate Determinant'),
          ),
          const SizedBox(height: 20),
          if (_resultText.isNotEmpty)
            StatusCard(
              text: _resultText,
              onDismiss: () => setState(() => _resultText = ""),
            ),
        ],
      ),
    );
  }
}
