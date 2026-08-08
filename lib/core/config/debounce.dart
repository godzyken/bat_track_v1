import 'dart:async';

import 'package:flutter/scheduler.dart';

class FrameSyncQueue<M> {
  final Future<void> Function(List<M>) onBatch;

  final Map<String, M> _buffer = {};
  bool _scheduled = false;

  FrameSyncQueue({required this.onBatch});

  void add(M item) {
    final String id = (item as dynamic).id.toString();
    _buffer[id] = item;

    if (_scheduled) return;

    _scheduled = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      scheduleMicrotask(_flush);
    });
  }

  Future<void> _flush() async {
    _scheduled = false;

    if (_buffer.isEmpty) return;

    final batch = _buffer.values.toList();
    _buffer.clear();

    try {
      await onBatch(batch);
    } catch (e) {
      for (final item in batch) {
        _buffer[(item as dynamic).id.toString()] = item;
      }
    }
  }
}
