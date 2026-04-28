// lib/core/riverpod/mutation_queue_mixin.dart
mixin MutationQueueMixin {
  final List<Future<void> Function()> _mutationQueue = [];
  bool _isProcessingQueue = false;

  Future<void> enqueueMutation(Future<void> Function() action) {
    _mutationQueue.add(action);
    return _processQueue();
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
        onMutationError(e, st);
        break;
      }
    }
    _isProcessingQueue = false;
  }

  void onMutationError(Object e, StackTrace st);
}
