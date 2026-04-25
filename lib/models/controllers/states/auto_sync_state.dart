class AutoSyncState {
  final bool isSyncing;
  final DateTime? lastSync;
  final Object? lastError;

  const AutoSyncState({this.isSyncing = false, this.lastSync, this.lastError});

  AutoSyncState copyWith({
    bool? isSyncing,
    DateTime? lastSync,
    Object? lastError,
  }) {
    return AutoSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSync: lastSync ?? this.lastSync,
      lastError: lastError,
    );
  }
}
