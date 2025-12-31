import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_calc_offline/logic/matrix.dart';
import 'package:matrix_calc_offline/logic/matrix_steps.dart';

void main() {
  test('determinantGaussianSteps with zero matrix', () {
    Matrix m = Matrix(3, 3); // Zeros
    var steps = m.determinantGaussianSteps();
    print("Steps count: ${steps.length}");
    for(var s in steps) {
      print(s.description);
    }
    expect(steps.isNotEmpty, true);
    expect(steps.any((s) => s.description.contains("Determinant")), true);
  });
}
