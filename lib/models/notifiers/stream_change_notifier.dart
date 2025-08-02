import 'dart:async';

import 'package:flutter/cupertino.dart';

class StreamChangeNotifier extends ChangeNotifier {
  final StreamSubscription _subscription;

  StreamChangeNotifier(Stream<dynamic> stream)
    : _subscription = stream.listen((_) => _safeNotify());

  static void _safeNotify() {
    // Pour éviter les erreurs "setState() called after dispose"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifier?.notifyListeners();
    });
  }

  static StreamChangeNotifier? _notifier;

  static StreamChangeNotifier init(Stream stream) {
    _notifier = StreamChangeNotifier(stream);
    return _notifier!;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
