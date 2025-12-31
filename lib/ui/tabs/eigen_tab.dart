import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import '../../logic/matrix.dart';
import '../../logic/eigen_solver.dart';
import '../../logic/symbolic_matrix.dart';
import '../../logic/solution_step.dart';
import '../../logic/history_service.dart';
import '../matrix_input.dart';
import '../solution_screen.dart';

import '../home_screen.dart';
import '../common/status_card.dart';

class EigenTab extends StatefulWidget {
  final MatrixEvent? matrixEvent;
  const EigenTab({super.key, this.matrixEvent});

  @override
  State<EigenTab> createState() => EigenTabState();
}

class EigenTabState extends State<EigenTab> {
  int _size = 3;
  final List<List<TextEditingController>> _controllers = [];
  String _resultText = "";

  MatrixEvent? _lastProcessedEvent;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _checkEvents();
  }

  @override
  void didUpdateWidget(EigenTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkEvents();
  }

  void _checkEvents() {
    if (widget.matrixEvent != null && widget.matrixEvent != _lastProcessedEvent) {
      _lastProcessedEvent = widget.matrixEvent;
      setMatrixA(widget.matrixEvent!.matrix);
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
      }
    });
  }

  void _onMatrixCaptured(Matrix m) {
    setState(() {
      _size = m.rows;
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

  void _diagonalize() {
    try {
      // Parse input
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
      
      EigenSolver solver = EigenSolver();
      List<SolutionStep> steps = solver.getDiagonalization(matrix);

      // Log input to history
      HistoryService().add(matrix, "Diagonalize Input");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolutionScreen(steps: steps, title: "Diagonalization"),
        ),
      );
    } catch (e) {
      setState(() {
        _resultText = "Error: $e";
      });
    }
  }

  void _calculate() {
    try {
      // Try numeric first
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
        
        EigenSolver solver = EigenSolver();
        List<SolutionStep> steps = solver.getStepByStepSolution(matrix);

        // Log input to history
        HistoryService().add(matrix, "Eigen Input");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SolutionScreen(steps: steps),
          ),
        );
      } catch (e) {
        // Fallback to symbolic
        List<List<String>> rawData = [];
        for (int i = 0; i < _size; i++) {
          List<String> row = [];
          for (int j = 0; j < _size; j++) {
            row.add(_controllers[i][j].text);
          }
          rawData.add(row);
        }
        
        SymbolicMatrix symMatrix = SymbolicMatrix.fromStrings(rawData);
        EigenSolver solver = EigenSolver();
        List<SolutionStep> steps = solver.getSymbolicStepByStep(symMatrix);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SolutionScreen(steps: steps),
          ),
        );
      }
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
          ElevatedButton(
            onPressed: _calculate,
            child: const Text('Find Eigenvalues'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _diagonalize,
            child: const Text('Diagonalize Matrix'),
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
