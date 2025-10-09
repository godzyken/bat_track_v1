import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/core/unified_model.dart';

class DolibarrImportEntry<T extends UnifiedModel> {
  final String endpoint;
  final T Function(Map<String, dynamic>) fromJson;
  final Future<void> Function(WidgetRef ref, T model) saveFn;

  DolibarrImportEntry({
    required this.endpoint,
    required this.fromJson,
    required this.saveFn,
  });
}
