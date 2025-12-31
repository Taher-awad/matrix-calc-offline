import 'package:flutter/material.dart';
import '../../logic/history_service.dart';
import '../../logic/matrix.dart';
import '../matrix_widget.dart';

class HistoryTab extends StatefulWidget {
  final Function(Matrix matrix, String target) onUseMatrix;

  const HistoryTab({super.key, required this.onUseMatrix});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  void initState() {
    super.initState();
    HistoryService().addListener(_onHistoryChanged);
  }

  @override
  void dispose() {
    HistoryService().removeListener(_onHistoryChanged);
    super.dispose();
  }

  void _onHistoryChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final history = HistoryService().history;

    if (history.isEmpty) {
      return const Center(
        child: Text("No history yet. Perform calculations to see them here."),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.operation,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: MatrixWidget(matrix: item.result),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text("To Ops A"),
                      onPressed: () => widget.onUseMatrix(item.result, "Ops A"),
                      avatar: const Icon(Icons.arrow_forward, size: 16),
                    ),
                    ActionChip(
                      label: const Text("To Ops B"),
                      onPressed: () => widget.onUseMatrix(item.result, "Ops B"),
                      avatar: const Icon(Icons.arrow_forward, size: 16),
                    ),
                    ActionChip(
                      label: const Text("To Det"),
                      onPressed: () => widget.onUseMatrix(item.result, "Det"),
                      avatar: const Icon(Icons.arrow_forward, size: 16),
                    ),
                    ActionChip(
                      label: const Text("To Eigen"),
                      onPressed: () => widget.onUseMatrix(item.result, "Eigen"),
                      avatar: const Icon(Icons.arrow_forward, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
