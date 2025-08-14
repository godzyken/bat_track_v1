import 'package:flutter/material.dart';

class DebugLogEntry {
  final String title;
  final String? json;
  final DateTime timestamp;

  DebugLogEntry({required this.title, this.json}) : timestamp = DateTime.now();
}

class DebugOverlay {
  static final DebugOverlay _instance = DebugOverlay._internal();
  factory DebugOverlay() => _instance;
  DebugOverlay._internal();

  final ValueNotifier<List<DebugLogEntry>> logs = ValueNotifier([]);

  void log(String title, {String? json}) {
    logs.value = List.from(logs.value)
      ..add(DebugLogEntry(title: title, json: json));
  }

  void clear() {
    logs.value = [];
  }
}
