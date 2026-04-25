import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/core/models/unified_model.dart';

import '../../models/data/maperror/log_entry.dart';
import '../../models/notifiers/logged_notifier.dart';

abstract class BaseEntityNotifier<T extends UnifiedModel>
    extends AsyncNotifier<T?> {
  // ------------------------------------------------------------------
  // CONFIG
  // ------------------------------------------------------------------

  String get entityId;

  Future<T?> fetchById(String id);
  Future<void> save(T item);
  Future<void> delete(String id);

  @override
  Future<T?> build() => fetchById(entityId);

  // ------------------------------------------------------------------
  // HISTORY (undo / redo)
  // ------------------------------------------------------------------

  final ListQueue<T?> _undoStack = ListQueue();
  final ListQueue<T?> _redoStack = ListQueue();

  void _pushToUndo(T? snapshot) {
    _undoStack.addLast(snapshot);
    _redoStack.clear();

    if (_undoStack.length > 20) {
      _undoStack.removeFirst();
    }
  }

  // ------------------------------------------------------------------
  // MUTATION QUEUE (offline-ready)
  // ------------------------------------------------------------------

  final List<Future<void> Function()> _mutationQueue = [];
  bool _isProcessingQueue = false;

  void _enqueueMutation(Future<void> Function() action) {
    _mutationQueue.add(action);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;

    _isProcessingQueue = true;

    while (_mutationQueue.isNotEmpty) {
      final action = _mutationQueue.first;

      try {
        await action();
        _mutationQueue.removeAt(0);
      } catch (e, st) {
        _handleError(e, st);
        break; // stop queue
      }
    }

    _isProcessingQueue = false;
  }

  // ------------------------------------------------------------------
  // UPDATE (optimistic)
  // ------------------------------------------------------------------

  Future<void> updateEntity(T item) async {
    final previous = state.value;

    _pushToUndo(previous);

    state = AsyncData(item);

    _enqueueMutation(() async {
      await save(item);
      _log('update', id: item.id);
    });
  }

  // ------------------------------------------------------------------
  // DELETE (optimistic)
  // ------------------------------------------------------------------

  Future<void> deleteEntity() async {
    final previous = state.value;

    _pushToUndo(previous);

    state = const AsyncData(null);

    _enqueueMutation(() async {
      await delete(entityId);
      _log('delete', id: entityId);
    });
  }

  // ------------------------------------------------------------------
  // REFRESH
  // ------------------------------------------------------------------

  Future<void> refresh() async {
    try {
      final result = await fetchById(entityId);
      state = AsyncData(result);
    } catch (e, st) {
      _handleError(e, st);
    }
  }

  // ------------------------------------------------------------------
  // UNDO / REDO
  // ------------------------------------------------------------------

  void undo() {
    if (_undoStack.isEmpty) return;

    final current = state.value;
    _redoStack.addFirst(current);

    final previous = _undoStack.removeLast();
    state = AsyncData(previous);

    _log('undo');
  }

  void redo() {
    if (_redoStack.isEmpty) return;

    final current = state.value;
    _undoStack.addLast(current);

    final next = _redoStack.removeFirst();
    state = AsyncData(next);

    _log('redo');
  }

  // ------------------------------------------------------------------
  // REPLAY (debug)
  // ------------------------------------------------------------------

  Future<void> replayQueue() async {
    _log('replay_start');

    final queueCopy = List.of(_mutationQueue);

    for (final action in queueCopy) {
      try {
        await action();
      } catch (e, st) {
        _handleError(e, st);
      }
    }

    _log('replay_end');
  }

  // ------------------------------------------------------------------
  // LOGGING
  // ------------------------------------------------------------------

  void _log(String action, {String? id}) {
    ref
        .read(loggerNotifierProvider.notifier)
        .log(
          LogEntry(
            action: action,
            target: T.toString(),
            entityId: id,
            timestamp: DateTime.now(),
          ),
        );
  }

  void _handleError(Object e, StackTrace st) {
    ref
        .read(loggerNotifierProvider.notifier)
        .log(
          LogEntry(
            action: 'ERROR',
            target: T.toString(),
            data: {'error': e.toString()},
            timestamp: DateTime.now(),
          ),
        );
  }
}
