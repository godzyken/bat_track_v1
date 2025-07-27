import 'package:flutter/foundation.dart';

@immutable
class SyncedState<T> {
  final T data;
  final DateTime? lastSynced;
  final bool isSyncing;
  final bool hasError;

  const SyncedState({
    required this.data,
    this.lastSynced,
    this.isSyncing = false,
    this.hasError = false,
  });

  /// Factory pratique pour créer un état initial
  factory SyncedState.initial(T data) => SyncedState(data: data);
  factory SyncedState.error(T data) =>
      SyncedState(data: data, isSyncing: false, hasError: true);
  factory SyncedState.loading(T data) =>
      SyncedState(data: data, isSyncing: true, hasError: false);

  SyncedState<T> copyWith({
    T? data,
    DateTime? lastSynced,
    bool? isSyncing,
    bool? hasError,
  }) {
    return SyncedState(
      data: data ?? this.data,
      lastSynced: lastSynced ?? this.lastSynced,
      isSyncing: isSyncing ?? this.isSyncing,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  String toString() {
    return 'SyncedState<$T>(data: $data, lastSynced: $lastSynced, '
        'isSyncing: $isSyncing, hasError: $hasError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SyncedState<T> &&
            runtimeType == other.runtimeType &&
            data == other.data &&
            lastSynced == other.lastSynced &&
            isSyncing == other.isSyncing &&
            hasError == other.hasError;
  }

  @override
  int get hashCode =>
      data.hashCode ^
      lastSynced.hashCode ^
      isSyncing.hashCode ^
      hasError.hashCode;
}
