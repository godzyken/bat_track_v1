import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/core/models/unified_model.dart';

import '../../models/data/maperror/log_entry.dart';
import '../../models/notifiers/logged_notifier.dart';

abstract class BaseListNotifier<T extends UnifiedModel>
    extends AsyncNotifier<List<T>> {
  // ------------------------------------------------------------------
  // HISTORY (undo / redo)
  // ------------------------------------------------------------------

  final ListQueue<List<T>> _undoStack = ListQueue();
  final ListQueue<List<T>> _redoStack = ListQueue();

  // ------------------------------------------------------------------
  // MUTATION QUEUE (offline ready)
  // ------------------------------------------------------------------

  final List<Future<void> Function()> _mutationQueue = [];

  bool _isProcessingQueue = false;

  // ------------------------------------------------------------------
  // ABSTRACT
  // ------------------------------------------------------------------

  Future<List<T>> fetchAll();
  Future<void> save(T item);
  Future<void> delete(String id);

  @override
  Future<List<T>> build() => fetchAll();

  // ------------------------------------------------------------------
  // REFRESH
  // ------------------------------------------------------------------

  Future<void> refresh() async {
    try {
      final result = await fetchAll();
      state = AsyncData(result);
    } catch (e, st) {
      _handleError(e, st);
    }
  }

  // ------------------------------------------------------------------
  // ADD
  // ------------------------------------------------------------------

  Future<void> addItem(T item) async {
    final previous = state.value ?? [];

    _pushToUndo(previous);

    final updated = [...previous, item];
    state = AsyncData(updated);

    _enqueueMutation(() async {
      await save(item);
      _log('add', id: item.id);
    });
  }

  // ------------------------------------------------------------------
  // UPDATE
  // ------------------------------------------------------------------

  Future<void> updateItem(T item) async {
    final previous = state.value ?? [];

    _pushToUndo(previous);

    final updated = previous.map((e) => e.id == item.id ? item : e).toList();

    state = AsyncData(updated);

    _enqueueMutation(() async {
      await save(item);
      _log('update', id: item.id);
    });
  }

  // ------------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------------

  Future<void> removeItem(String id) async {
    final previous = state.value ?? [];

    _pushToUndo(previous);

    final updated = previous.where((e) => e.id != id).toList();

    state = AsyncData(updated);

    _enqueueMutation(() async {
      await delete(id);
      _log('delete', id: id);
    });
  }

  // ------------------------------------------------------------------
  // UNDO / REDO
  // ------------------------------------------------------------------

  void undo() {
    if (_undoStack.isEmpty) return;

    final current = state.value ?? [];
    _redoStack.addFirst(current);

    final previous = _undoStack.removeLast();
    state = AsyncData(previous);

    _log('undo');
  }

  void redo() {
    if (_redoStack.isEmpty) return;

    final current = state.value ?? [];
    _undoStack.addLast(current);

    final next = _redoStack.removeFirst();
    state = AsyncData(next);

    _log('redo');
  }

  void _pushToUndo(List<T> stateSnapshot) {
    _undoStack.addLast(List.from(stateSnapshot));
    _redoStack.clear();

    // limite mémoire
    if (_undoStack.length > 20) {
      _undoStack.removeFirst();
    }
  }

  // ------------------------------------------------------------------
  // MUTATION QUEUE (offline-first)
  // ------------------------------------------------------------------

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

        // stop queue → retry plus tard
        break;
      }
    }

    _isProcessingQueue = false;
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
