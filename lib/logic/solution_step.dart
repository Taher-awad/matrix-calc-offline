import 'matrix.dart';

class SolutionStep {
  final String description;
  final Matrix? matrixState;

  SolutionStep(this.description, [this.matrixState]);
}
