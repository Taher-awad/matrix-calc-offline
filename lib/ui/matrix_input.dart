import 'package:flutter/material.dart';
import '../logic/matrix.dart';

class MatrixInput extends StatelessWidget {
  final String label;
  final List<List<TextEditingController>> controllers;
  final int rows;
  final int cols;
  final Function(int, int) onResize;
  final Function(Matrix)? onMatrixCaptured; // Kept for API compatibility but unused for OCR now

  const MatrixInput({
    super.key,
    required this.label,
    required this.controllers,
    required this.rows,
    required this.cols,
    required this.onResize,
    this.onMatrixCaptured,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () => onResize(-1, 0), icon: const Icon(Icons.remove, size: 16)),
            Text('$rows'),
            IconButton(onPressed: () => onResize(1, 0), icon: const Icon(Icons.add, size: 16)),
            const Text('x'),
            IconButton(onPressed: () => onResize(0, -1), icon: const Icon(Icons.remove, size: 16)),
            Text('$cols'),
            IconButton(onPressed: () => onResize(0, 1), icon: const Icon(Icons.add, size: 16)),
          ],
        ),
        SizedBox(
          height: rows * 50.0,
          width: cols * 60.0,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: 1.5,
            ),
            itemCount: rows * cols,
            itemBuilder: (context, index) {
              int r = index ~/ cols;
              int c = index % cols;
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: TextField(
                  controller: controllers[r][c],
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
