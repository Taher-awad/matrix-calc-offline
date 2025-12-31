import 'package:flutter/material.dart';
import '../logic/solution_step.dart';
import 'matrix_widget.dart';

class SolutionScreen extends StatelessWidget {
  final List<SolutionStep> steps;
  final String? title;

  const SolutionScreen({super.key, required this.steps, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Solution'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${index + 1}: ${step.description}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Divider(height: 24),
                  if (step.matrixState != null)
                    Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: MatrixWidget(
                          matrix: step.matrixState!,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
