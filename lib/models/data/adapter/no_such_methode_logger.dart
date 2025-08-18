import 'dart:developer' as developer;

/// Mixin qui loggue les appels inconnus.
/// Peut aussi déléguer à un `proxyTarget` si défini.
mixin NoSuchMethodLogger {
  /// Instance cible vers laquelle déléguer (ex: FirebaseStorage ou Firestore).
  dynamic get proxyTarget => null;

  void _logInvocation(Invocation invocation) {
    developer.log(
      '[$runtimeType] noSuchMethod: '
      '${invocation.memberName} '
      'args: ${invocation.positionalArguments} '
      'named: ${invocation.namedArguments}',
      name: runtimeType.toString(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    _logInvocation(invocation);

    if (proxyTarget != null) {
      try {
        return Function.apply(
          (proxyTarget as dynamic).noSuchMethod(invocation)
              as dynamic Function(),
          invocation.positionalArguments,
          invocation.namedArguments,
        );
      } catch (e, st) {
        developer.log(
          '[$runtimeType] Proxy failed for ${invocation.memberName}',
          error: e,
          stackTrace: st,
        );
      }
    }

    return super.noSuchMethod(invocation);
  }
}
