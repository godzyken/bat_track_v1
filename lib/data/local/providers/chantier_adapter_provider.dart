import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/adapters/json_adapter.dart';

final chantierAdapterProvider = Provider<ChantierAdapter>((ref) {
  return ChantierAdapter();
});
