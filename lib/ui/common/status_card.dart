import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final VoidCallback? onDismiss;

  const StatusCard({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Card(
      color: color ?? Colors.red.shade50,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                  color: textColor ?? Colors.red.shade900,
                ),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: Icon(Icons.close, color: textColor ?? Colors.red.shade900, size: 20),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
