import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

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
