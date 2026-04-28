// lib/core/riverpod/undo_redo_mixin.dart
import 'dart:collection';

mixin UndoRedoMixin<T> {
  final ListQueue<T> _undoStack = ListQueue();
  final ListQueue<T> _redoStack = ListQueue();
  static const int _maxHistory = 20;

  void pushToUndo(T snapshot) {
    _undoStack.addLast(snapshot);
    _redoStack.clear();
    if (_undoStack.length > _maxHistory) _undoStack.removeFirst();
  }

  T? popUndo() => _undoStack.isNotEmpty ? _undoStack.removeLast() : null;

  void pushToRedo(T snapshot) => _redoStack.addFirst(snapshot);

  T? popRedo() => _redoStack.isNotEmpty ? _redoStack.removeFirst() : null;

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
}
