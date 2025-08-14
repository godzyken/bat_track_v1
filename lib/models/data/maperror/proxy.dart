import 'dart:convert';

import 'package:bat_track_v1/models/data/maperror/debug_config.dart';
import 'package:flutter/foundation.dart';

typedef CallInterceptor =
    dynamic Function(
      String methodName,
      List<dynamic> positionalArguments,
      Map<Symbol, dynamic> namedArguments,
      Function originalCall,
    );

typedef MethodFilter = bool Function(String methodName);

class DebugProxy<T> {
  final T _inner;
  final T? monitoredItem;
  final MethodFilter? logFilter;
  final CallInterceptor? interceptor;

  DebugProxy(
    this._inner, {
    this.logFilter,
    this.interceptor,
    this.monitoredItem,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final methodName = invocation.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');

    // Logging
    final arguments = invocation.positionalArguments;

    String? json;
    if (monitoredItem != null) {
      try {
        json = jsonEncode(monitoredItem);
      } catch (_) {}
    }

    if (kDebugMode && (logFilter == null || logFilter!(methodName))) {
      DebugOverlay().log(
        '[DEBUG][${T.toString()}] $methodName called with $arguments',
        json: json,
      );
    }

    // Interception
    if (interceptor != null) {
      return interceptor!(
        methodName,
        arguments,
        invocation.namedArguments,
        () => Function.apply(
          _getMethod(_inner as dynamic, invocation.memberName),
          arguments,
          invocation.namedArguments,
        ),
      );
    }

    return Function.apply(
      _getMethod(_inner as dynamic, invocation.memberName),
      arguments,
      invocation.namedArguments,
    );
  }

  dynamic _getMethod(Object obj, Symbol memberName) {
    try {
      final dyn = obj as dynamic;
      return dyn;
    } catch (_) {
      return null;
    }
  }
}
