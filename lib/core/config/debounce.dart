import 'dart:async';

import 'package:flutter/scheduler.dart';

class FrameSyncQueue<M> {
  final Future<void> Function(List<M>) onBatch;

  final Map<String, M> _buffer = {};
  bool _scheduled = false;

  FrameSyncQueue({required this.onBatch});

  void add(M item) {
    final id = (item as dynamic).id;
    _buffer[id] = item;

    if (_scheduled) return;

    _scheduled = true;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
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
      _buffer.addAll(batch); // retry plus tard
    }
  }
}
