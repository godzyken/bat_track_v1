import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../models/data/maperror/log_entry.dart';
import '../../models/notifiers/logged_notifier.dart';
import 'mutation_queue_mixin.dart';
import 'undo_redo_mixin.dart';

abstract class BaseListNotifier<T extends UnifiedModel>
    extends AsyncNotifier<List<T>>
    with MutationQueueMixin, UndoRedoMixin<List<T>> {
  // ── À implémenter ──────────────────────────────────────────────
  Future<List<T>> fetchAll();
  Future<void> save(T item);
  Future<void> delete(String id);

  @override
  Future<List<T>> build() => fetchAll();

  // ── Lecture ────────────────────────────────────────────────────
  Future<void> refresh() async {
    try {
      state = AsyncData(await fetchAll());
    } catch (e, st) {
      _handleError(e, st);
    }
  }

  // ── Mutations optimistes ───────────────────────────────────────
  Future<void> addItem(T item) async {
    final previous = state.value ?? [];
    pushToUndo(List.from(previous));
    state = AsyncData([...previous, item]);
    await enqueueMutation(() async {
      await save(item);
      _log('add', id: item.id);
    });
  }

  Future<void> updateItem(T item) async {
    final previous = state.value ?? [];
    pushToUndo(List.from(previous));
    state = AsyncData(previous.map((e) => e.id == item.id ? item : e).toList());
    await enqueueMutation(() async {
      await save(item);
      _log('update', id: item.id);
    });
  }

  Future<void> removeItem(String id) async {
    final previous = state.value ?? [];
    pushToUndo(List.from(previous));
    state = AsyncData(previous.where((e) => e.id != id).toList());
    await enqueueMutation(() async {
      await delete(id);
      _log('delete', id: id);
    });
  }

  // ── Undo / Redo ────────────────────────────────────────────────
  void undo() {
    final current = state.value ?? [];
    final previous = popUndo();
    if (previous == null) return;
    pushToRedo(List.from(current));
    state = AsyncData(previous);
    _log('undo');
  }

  void redo() {
    final current = state.value ?? [];
    final next = popRedo();
    if (next == null) return;
    pushToUndo(List.from(current));
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
