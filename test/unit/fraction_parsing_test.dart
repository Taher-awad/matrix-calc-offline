import 'package:flutter_test/flutter_test.dart';
import 'package:fraction/fraction.dart';
import 'package:matrix_calc_offline/logic/matrix.dart';

void main() {
  test('Matrix.safeParseFraction parses decimal strings', () {
    String input = "0.712559";
    try {
      Fraction f = Matrix.safeParseFraction(input);
      print("Parsed successfully: $f");
      expect(f.toDouble(), closeTo(0.712559, 0.000001));
    } catch (e) {
      print("Error parsing '$input': $e");
      rethrow;
    }
  });

  test('Matrix.safeParseFraction parses integer strings', () {
    String input = "12559";
    Fraction f = Matrix.safeParseFraction(input);
    expect(f.toDouble().toInt(), 12559);
  });
}
