import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../models/data/maperror/log_entry.dart';
import '../../models/notifiers/logged_notifier.dart';
import 'mutation_queue_mixin.dart';
import 'undo_redo_mixin.dart';

abstract class BaseEntityNotifier<T extends UnifiedModel>
    extends AsyncNotifier<T?>
    with MutationQueueMixin, UndoRedoMixin<T?> {
  // ── À implémenter ──────────────────────────────────────────────
  String get entityId;
  Future<T?> fetchById(String id);
  Future<void> save(T item);
  Future<void> delete(String id);

  @override
  Future<T?> build() => fetchById(entityId);

  // ── Mutations ──────────────────────────────────────────────────
  Future<void> updateEntity(T item) async {
    pushToUndo(state.value);
    state = AsyncData(item);
    await enqueueMutation(() async {
      await save(item);
      _log('update', id: item.id);
    });
  }

  Future<void> deleteEntity() async {
    pushToUndo(state.value);
    state = const AsyncData(null);
    await enqueueMutation(() async {
      await delete(entityId);
      _log('delete', id: entityId);
    });
  }

  Future<void> refresh() async {
    try {
      state = AsyncData(await fetchById(entityId));
    } catch (e, st) {
      _handleError(e, st);
    }
  }

  // ── Undo / Redo ────────────────────────────────────────────────
  void undo() {
    final current = state.value;
    final previous = popUndo();
    if (previous == null && !canUndo) return;
    pushToRedo(current);
    state = AsyncData(previous);
    _log('undo');
  }

  void redo() {
    final current = state.value;
    final next = popRedo();
    if (next == null) return;
    pushToUndo(current);
    state = AsyncData(next);
    _log('redo');
  }

  // ── MutationQueueMixin impl ────────────────────────────────────
  @override
  void onMutationError(Object e, StackTrace st) => _handleError(e, st);

  // ── Logging ────────────────────────────────────────────────────
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
