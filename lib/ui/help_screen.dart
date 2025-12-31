import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _HelpSection(
            title: 'General Overview',
            content: 'Matrix Calculator Pro is a powerful offline tool for linear algebra operations. '
                'It supports matrix arithmetic, system solving, determinants, eigenvalues, and more. '
                'All calculations are performed locally on your device.',
          ),
          _HelpSection(
            title: 'System of Equations',
            content: 'Solve systems of linear equations (Ax = B).\n\n'
                '1. Enter the number of variables (Rows/Cols).\n'
                '2. Input the coefficients matrix (left) and constants vector (right).\n'
                '3. Select a method:\n'
                '   - Gaussian Elimination: Standard row reduction.\n'
                '   - Gauss-Jordan: Reduces to Reduced Row Echelon Form (RREF).\n'
                '   - Cramer\'s Rule: Uses determinants (Square matrices only).\n'
                '   - Inverse Matrix: X = A⁻¹B (Square matrices only).\n'
                '   - Least Squares: Finds approximate solution for overdetermined systems.',
          ),
          _HelpSection(
            title: 'Matrix Operations',
            content: 'Perform operations on one or two matrices.\n\n'
                '1. Enter dimensions and values for Matrix A and/or B.\n'
                '2. Use the buttons between matrices for binary operations:\n'
                '   - A+B, A-B: Addition/Subtraction (Must have same dimensions).\n'
                '   - AxB: Multiplication (Cols A must equal Rows B).\n'
                '   - Swap: Swaps Matrix A and B.\n'
                '3. Use buttons below for unary operations on Matrix A:\n'
                '   - Trans(A): Transpose.\n'
                '   - Inv(A): Inverse (Square only).\n'
                '   - Rank(A): Rank of the matrix.\n'
                '   - Det(A): Determinant.\n'
                '   - REF/RREF: Row Echelon Forms.\n'
                '   - A*k: Scalar multiplication (Enter k).\n'
                '   - A^n: Matrix power (Enter n).',
          ),
          _HelpSection(
            title: 'Determinant',
            content: 'Calculate the determinant of a square matrix.\n\n'
                '1. Enter the matrix size and values.\n'
                '2. Select a calculation method:\n'
                '   - Gaussian Elimination: Efficient for large matrices.\n'
                '   - Triangle Rule / Sarrus: For 3x3 matrices.\n'
                '   - Montante\'s Method: Bareiss algorithm (integers).\n'
                '   - Laplace Expansion: Expand along a specific row or column.',
          ),
          _HelpSection(
            title: 'Eigenvalues',
            content: 'Find eigenvalues and eigenvectors.\n\n'
                '1. Enter a square matrix.\n'
                '2. Click "Find Eigenvalues" to see step-by-step calculation.\n'
                '3. Click "Diagonalize Matrix" to find P and D such that A = PDP⁻¹.',
          ),
          _HelpSection(
            title: 'History',
            content: 'View and reuse past calculations.\n\n'
                '1. All successful operations are saved automatically.\n'
                '2. Go to the History tab to view the list.\n'
                '3. Tap "To Ops A", "To Ops B", etc., to load a result back into an input tab.\n'
                '4. History is persistent and saved across app restarts.',
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final String content;

  const _HelpSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content, style: const TextStyle(height: 1.5)),
          ),
        ],
      ),
    );
  }
}
