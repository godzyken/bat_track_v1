import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/dolibarr_loader.dart';
import '../services/dolibarr_services.dart';
import 'dolibarr_instance_provider.dart';

final dolibarrConfigProvider = FutureProvider<DolibarrConfig>((ref) async {
  return await DolibarrConfigLoader.load();
});

final dolibarrApiProvider = Provider<DolibarrApiService>((ref) {
  final instance = ref.watch(selectedInstanceProvider).value;
  return DolibarrApiService(baseUrl: instance!.baseUrl, token: instance.apiKey);
});
