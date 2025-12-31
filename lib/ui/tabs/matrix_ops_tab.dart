import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import '../../logic/matrix.dart';
import '../../logic/matrix_steps.dart';
import '../matrix_input.dart';
import '../solution_screen.dart';
import '../../logic/solution_step.dart';
import '../../logic/history_service.dart';

import '../home_screen.dart'; // For MatrixEvent
import '../common/status_card.dart';

class MatrixOpsTab extends StatefulWidget {
  final MatrixEvent? matrixAEvent;
  final MatrixEvent? matrixBEvent;

  const MatrixOpsTab({
    super.key,
    this.matrixAEvent,
    this.matrixBEvent,
  });

  @override
  State<MatrixOpsTab> createState() => MatrixOpsTabState();
}

class MatrixOpsTabState extends State<MatrixOpsTab> {
  int _rowsA = 3;
  int _colsA = 3;
  int _rowsB = 3;
  int _colsB = 3;

  final List<List<TextEditingController>> _controllersA = [];
  final List<List<TextEditingController>> _controllersB = [];
  
  String _errorText = "";

  MatrixEvent? _lastProcessedAEvent;
  MatrixEvent? _lastProcessedBEvent;

  @override
  void initState() {
    super.initState();
    _initControllers(_controllersA, _rowsA, _colsA);
    _initControllers(_controllersB, _rowsB, _colsB);
    _checkEvents();
  }

  @override
  void didUpdateWidget(MatrixOpsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkEvents();
  }

  void _checkEvents() {
    if (widget.matrixAEvent != null && widget.matrixAEvent != _lastProcessedAEvent) {
      _lastProcessedAEvent = widget.matrixAEvent;
      setMatrixA(widget.matrixAEvent!.matrix);
    }
    if (widget.matrixBEvent != null && widget.matrixBEvent != _lastProcessedBEvent) {
      _lastProcessedBEvent = widget.matrixBEvent;
      setMatrixB(widget.matrixBEvent!.matrix);
    }
  }

  void _initControllers(List<List<TextEditingController>> controllers, int rows, int cols) {
    for (var row in controllers) {
      for (var c in row) {
        c.dispose();
      }
    }
    controllers.clear();
    for (int i = 0; i < rows; i++) {
      List<TextEditingController> row = [];
      for (int j = 0; j < cols; j++) {
        row.add(TextEditingController());
      }
      controllers.add(row);
    }
  }

  void _updateSizeA(int dRows, int dCols) {
    setState(() {
      int newRows = _rowsA + dRows;
      int newCols = _colsA + dCols;
      if (newRows >= 1 && newRows <= 5 && newCols >= 1 && newCols <= 5) {
        _rowsA = newRows;
        _colsA = newCols;
        _initControllers(_controllersA, _rowsA, _colsA);
      }
    });
  }

  void _updateSizeB(int dRows, int dCols) {
    setState(() {
      int newRows = _rowsB + dRows;
      int newCols = _colsB + dCols;
      if (newRows >= 1 && newRows <= 5 && newCols >= 1 && newCols <= 5) {
        _rowsB = newRows;
        _colsB = newCols;
        _initControllers(_controllersB, _rowsB, _colsB);
      }
    });
  }

  Matrix _getMatrix(List<List<TextEditingController>> controllers, int rows, int cols) {
    List<List<Fraction>> data = [];
    for (int i = 0; i < rows; i++) {
      List<Fraction> row = [];
      for (int j = 0; j < cols; j++) {
        String text = controllers[i][j].text;
        row.add(Matrix.safeParseFraction(text));
      }
      data.add(row);
    }
    return Matrix.fromData(data);
  }

  Matrix? _lastResultMatrix;

  final TextEditingController _scalarController = TextEditingController();

  @override
  void dispose() {
    _scalarController.dispose();
    super.dispose();
  }

  void _performOp(String op) {
    setState(() => _errorText = "");
    try {
      Matrix A = _getMatrix(_controllersA, _rowsA, _colsA);
      Matrix? B;
      if (['A+B', 'A-B', 'AxB'].contains(op)) {
        B = _getMatrix(_controllersB, _rowsB, _colsB);
      }

      List<SolutionStep> steps = [];
      
      if (op == 'A+B') {
        steps = A.additionSteps(B!);
      } else if (op == 'A-B') steps = A.subtractionSteps(B!);
      else if (op == 'AxB') steps = A.multiplicationSteps(B!);
      else if (op == 'Trans(A)') steps = A.transposeSteps();
      else if (op == 'Inv(A)') steps = A.inverseSteps();
      else if (op == 'Rank(A)') steps = A.rankSteps();
      else if (op == 'Det(A)') steps = A.determinantGaussianSteps(); // Default to Gaussian for Ops tab
      else if (op == 'REF(A)') steps = A.triangleSteps(); // REF
      else if (op == 'RREF(A)') steps = A.rrefSteps();
      else if (op == 'Triangle(A)') steps = A.triangleSteps();
      else if (op == 'A*k') {
        if (_scalarController.text.isEmpty) throw Exception("Enter a scalar value k");
        Fraction k = Fraction.fromString(_scalarController.text);
        steps = A.scalarMultiplicationSteps(k);
      }
      else if (op == 'A^n') {
        if (_scalarController.text.isEmpty) throw Exception("Enter an integer power n");
        int n = int.parse(_scalarController.text);
        steps = A.powerSteps(n);
      }
      
      if (steps.isNotEmpty) {
        // Find the result matrix from the last step?
        // Usually the last step has the result.
        // Or we can capture it from the logic methods if they returned it.
        // But logic methods return List<SolutionStep>.
        // Let's inspect the last step.
        if (steps.last.matrixState != null) {
          HistoryService().add(steps.last.matrixState!, op);
        }



        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SolutionScreen(
              title: "Result: $op",
              steps: steps,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorText = "Error: $e";
      });
    }
  }

  void _swapMatrices() {
    setState(() {
      // Swap sizes
      int tempRows = _rowsA;
      int tempCols = _colsA;
      _rowsA = _rowsB;
      _colsA = _colsB;
      _rowsB = tempRows;
      _colsB = tempCols;
      
      // Swap data
      // We need to extract data first because controllers are tied to size
      List<List<String>> dataA = [];
      for(var row in _controllersA) {
        dataA.add(row.map((c) => c.text).toList());
      }
      
      List<List<String>> dataB = [];
      for(var row in _controllersB) {
        dataB.add(row.map((c) => c.text).toList());
      }
      
      // Re-init controllers with new sizes
      _initControllers(_controllersA, _rowsA, _colsA);
      _initControllers(_controllersB, _rowsB, _colsB);
      
      // Fill with swapped data
      for(int i=0; i<_rowsA && i<dataB.length; i++) {
        for(int j=0; j<_colsA && j<dataB[i].length; j++) {
          _controllersA[i][j].text = dataB[i][j];
        }
      }
      
      for(int i=0; i<_rowsB && i<dataA.length; i++) {
        for(int j=0; j<_colsB && j<dataA[i].length; j++) {
          _controllersB[i][j].text = dataA[i][j];
        }
      }
    });
  }

  void _copyTo(String target) {
    if (_lastResultMatrix == null) return;
    
    Matrix m = _lastResultMatrix!;
    setState(() {
      if (target == 'A') {
        if (m.rows != _rowsA || m.cols != _colsA) {
          _rowsA = m.rows;
          _colsA = m.cols;
          _initControllers(_controllersA, _rowsA, _colsA);
        }
        for(int i=0; i<m.rows; i++) {
          for(int j=0; j<m.cols; j++) {
            _controllersA[i][j].text = Matrix.formatValueForInput(m.get(i, j));
          }
        }
      } else if (target == 'B') {
        if (m.rows != _rowsB || m.cols != _colsB) {
          _rowsB = m.rows;
          _colsB = m.cols;
          _initControllers(_controllersB, _rowsB, _colsB);
        }
        for(int i=0; i<m.rows; i++) {
          for(int j=0; j<m.cols; j++) {
            _controllersB[i][j].text = Matrix.formatValueForInput(m.get(i, j));
          }
        }
      }
    });
  }

  void setMatrixA(Matrix m) {
    _onMatrixCaptured(m, _controllersA, _updateSizeA, (r, c) => _updateSizeA(r - _rowsA, c - _colsA));
  }

  void setMatrixB(Matrix m) {
    _onMatrixCaptured(m, _controllersB, _updateSizeB, (r, c) => _updateSizeB(r - _rowsB, c - _colsB));
  }

  void _onMatrixCaptured(Matrix m, List<List<TextEditingController>> controllers, Function(int, int) resize, Function(int, int) setSize) {
    print("Matrix captured: ${m.rows}x${m.cols}");
    setState(() {
      // Resize if needed
      // We need a way to set exact size, but resize takes delta.
      // Let's just re-init controllers with new size directly
      // This is a bit hacky with current structure, but works.
      // Better: update state variables directly.
      
      if (controllers == _controllersA) {
        _rowsA = m.rows;
        _colsA = m.cols;
        _initControllers(_controllersA, _rowsA, _colsA);
      } else {
        _rowsB = m.rows;
        _colsB = m.cols;
        _initControllers(_controllersB, _rowsB, _colsB);
      }

      for(int i=0; i<m.rows; i++) {
        for(int j=0; j<m.cols; j++) {
          controllers[i][j].text = Matrix.formatValueForInput(m.get(i, j));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_errorText.isNotEmpty)
            StatusCard(
              text: _errorText,
              onDismiss: () => setState(() => _errorText = ""),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MatrixInput(
                      label: "Matrix A",
                      controllers: _controllersA,
                      rows: _rowsA,
                      cols: _colsA,
                      onResize: _updateSizeA,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        const SizedBox(height: 50),
                        ElevatedButton(onPressed: _swapMatrices, child: const Icon(Icons.swap_horiz)),
                        const SizedBox(height: 20),
                        ElevatedButton(onPressed: () => _performOp('A+B'), child: const Text('+')),
                        const SizedBox(height: 10),
                        ElevatedButton(onPressed: () => _performOp('A-B'), child: const Text('-')),
                        const SizedBox(height: 10),
                        ElevatedButton(onPressed: () => _performOp('AxB'), child: const Text('×')),
                      ],
                    ),
                    const SizedBox(width: 20),
                    MatrixInput(
                      label: "Matrix B",
                      controllers: _controllersB,
                      rows: _rowsB,
                      cols: _colsB,
                      onResize: _updateSizeB,
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    MatrixInput(
                      label: "Matrix A",
                      controllers: _controllersA,
                      rows: _rowsA,
                      cols: _colsA,
                      onResize: _updateSizeA,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(onPressed: _swapMatrices, child: const Icon(Icons.swap_vert)),
                        const SizedBox(width: 20),
                        ElevatedButton(onPressed: () => _performOp('A+B'), child: const Text('+')),
                        const SizedBox(width: 10),
                        ElevatedButton(onPressed: () => _performOp('A-B'), child: const Text('-')),
                        const SizedBox(width: 10),
                        ElevatedButton(onPressed: () => _performOp('AxB'), child: const Text('×')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MatrixInput(
                      label: "Matrix B",
                      controllers: _controllersB,
                      rows: _rowsB,
                      cols: _colsB,
                      onResize: _updateSizeB,
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),
          // Scalar/Power Input
          SizedBox(
            width: 150,
            child: TextField(
              controller: _scalarController,
              decoration: const InputDecoration(
                labelText: "Scalar k / Power n",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(onPressed: () => _performOp('Trans(A)'), child: const Text('Trans(A)')),
              ElevatedButton(onPressed: () => _performOp('Inv(A)'), child: const Text('Inv(A)')),
              ElevatedButton(onPressed: () => _performOp('Rank(A)'), child: const Text('Rank(A)')),
              ElevatedButton(onPressed: () => _performOp('Det(A)'), child: const Text('Det(A)')),
              ElevatedButton(onPressed: () => _performOp('REF(A)'), child: const Text('REF(A)')),
              ElevatedButton(onPressed: () => _performOp('RREF(A)'), child: const Text('RREF(A)')),
              ElevatedButton(onPressed: () => _performOp('Triangle(A)'), child: const Text('Triangle(A)')),
              ElevatedButton(onPressed: () => _performOp('A*k'), child: const Text('A × k')),
              ElevatedButton(onPressed: () => _performOp('A^n'), child: const Text('A ^ n')),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
