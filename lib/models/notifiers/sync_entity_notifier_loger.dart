import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bat_track_v1/models/data/state_wrapper/wrappers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/core/unified_model.dart';
import '../data/maperror/debug_config.dart';

class SyncEntityNotifierLogger<T extends UnifiedModel>
    implements StateNotifier<SyncedState<T>> {
  final StateNotifier<SyncedState<T>> _inner;

  SyncEntityNotifierLogger(this._inner);

  void _log(String methodName, [dynamic extra]) {
    try {
      final jsonString = jsonEncode(
        (_inner.state as dynamic).toJson?.call() ?? _inner.state,
      );
      DebugOverlay().log(
        '📡 $methodName sur ${T.toString()}',
        json: jsonString,
      );
      developer.log(
        '[SyncEntityNotifier] $methodName',
        name: 'SyncEntityNotifierLogger',
        error: extra,
      );
    } catch (e) {
      DebugOverlay().log('📡 $methodName (JSON invalide)');
    }
  }

  @override
  SyncedState<T> get state => _inner.state;

  @override
  set state(SyncedState<T> value) {
    _inner.state = value;
    _log('set state');
  }

  @override
  void dispose() {
    _log('dispose');
    _inner.dispose();
  }

  @override
  noSuchMethod(Invocation invocation) {
    final methodName = invocation.memberName.toString();
    _log(methodName, invocation.positionalArguments);
    final result = Function.apply(_inner.noSuchMethod, [invocation]);
    _log('$methodName terminé');
    return result;
  }
}
