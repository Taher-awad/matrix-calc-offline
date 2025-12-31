import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import '../logic/matrix.dart';

class MatrixWidget extends StatelessWidget {
  final Matrix matrix;
  final TextStyle? style;

  const MatrixWidget({super.key, required this.matrix, this.style});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MatrixBracketPainter(color: Colors.grey.shade800),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: List.generate(matrix.rows, (i) {
            return TableRow(
              children: List.generate(matrix.cols, (j) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  child: Center(child: _buildFractionWidget(matrix.get(i, j))),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFractionWidget(Fraction f) {
    final reduced = f.reduce();
    final textStyle = style ?? const TextStyle(fontSize: 18, fontFamily: 'serif', fontWeight: FontWeight.w500);

    if (reduced.isWhole) {
      return Text(reduced.numerator.toString(), style: textStyle);
    }
    
    if (reduced.denominator > 1000) {
      return Text(reduced.toDouble().toStringAsFixed(4), style: textStyle);
    }

    // Optimization: Use Column with IntrinsicWidth only if necessary?
    // Actually, for a fraction line, we need the width of the widest number.
    // IntrinsicWidth is the standard way.
    // But we can use a simpler structure.
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(reduced.numerator.toString(), style: textStyle, textAlign: TextAlign.center),
          Container(
            height: 1.5,
            color: Colors.black,
            margin: const EdgeInsets.symmetric(vertical: 2),
          ),
          Text(reduced.denominator.toString(), style: textStyle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _MatrixBracketPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double bracketWidth;
  final double cornerRadius;

  _MatrixBracketPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.bracketWidth = 8.0,
    this.cornerRadius = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    final path = Path();

    // Left Bracket
    path.moveTo(bracketWidth, 0);
    path.lineTo(cornerRadius, 0);
    path.quadraticBezierTo(0, 0, 0, cornerRadius);
    path.lineTo(0, size.height - cornerRadius);
    path.quadraticBezierTo(0, size.height, cornerRadius, size.height);
    path.lineTo(bracketWidth, size.height);

    // Right Bracket
    path.moveTo(size.width - bracketWidth, 0);
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);
    path.lineTo(size.width - bracketWidth, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MatrixBracketPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
