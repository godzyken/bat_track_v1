import 'dart:developer' as developer;

/// Mixin qui loggue les appels inconnus.
mixin NoSuchMethodLogger {
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
    return super.noSuchMethod(invocation);
  }
}
