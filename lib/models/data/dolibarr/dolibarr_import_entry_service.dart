import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../json_model.dart';

class DolibarrImportEntry<T extends JsonModel> {
  final String endpoint;
  final T Function(Map<String, dynamic>) fromJson;
  final Future<void> Function(WidgetRef ref, T model) saveFn;

  DolibarrImportEntry({
    required this.endpoint,
    required this.fromJson,
    required this.saveFn,
  });
}
