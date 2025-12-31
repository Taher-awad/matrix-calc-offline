import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'matrix.dart';

class HistoryItem {
  final Matrix result;
  final String operation;
  final DateTime timestamp;

  HistoryItem({
    required this.result,
    required this.operation,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'result': result.toJson(),
      'operation': operation,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      result: Matrix.fromJson(json['result']),
      operation: json['operation'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class HistoryService extends ChangeNotifier {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  
  HistoryService._internal() {
    _load();
  }

  final List<HistoryItem> _history = [];

  List<HistoryItem> get history => List.unmodifiable(_history.reversed);

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString('matrix_history');
      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _history.clear();
        _history.addAll(decoded.map((item) => HistoryItem.fromJson(item)).toList());
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_history.map((item) => item.toJson()).toList());
      await prefs.setString('matrix_history', encoded);
    } catch (e) {
      debugPrint("Error saving history: $e");
    }
  }

  void add(Matrix result, String operation) {
    _history.add(HistoryItem(
      result: result,
      operation: operation,
      timestamp: DateTime.now(),
    ));
    // Limit history size
    if (_history.length > 50) {
      _history.removeAt(0);
    }
    _save();
    notifyListeners();
  }

  void clear() {
    _history.clear();
    _save();
    notifyListeners();
  }
}
