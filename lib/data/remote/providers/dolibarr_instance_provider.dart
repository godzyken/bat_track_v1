import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../local/providers/shared_preferences_provider.dart';
import '../services/dolibarr_loader.dart';

final dolibarrInstancesProvider = FutureProvider<List<DolibarrInstance>>((
  ref,
) async {
  return DolibarrConfigLoader.loadInstances();
});

final selectedInstanceProvider =
    AsyncNotifierProvider<SelectedInstanceNotifier, DolibarrInstance?>(
      SelectedInstanceNotifier.new,
    );

class SelectedInstanceNotifier extends AsyncNotifier<DolibarrInstance?> {
  @override
  FutureOr<DolibarrInstance?> build() async {
    // Plus besoin de microtask ! Riverpod gère l'attente du futur.
    final prefs = await ref.watch(sharedPreferencesProvider.future);

    final url = prefs.getString('dolibarr_baseUrl');
    final apiKey = prefs.getString('dolibarr_apiKey');
    final name = prefs.getString('dolibarr_name');

    if (url == null || apiKey == null || name == null) return null;

    return DolibarrInstance(name: name, baseUrl: url, apiKey: apiKey);
  }

  // ------------------------------------------------------------------
  // SELECT
  // ------------------------------------------------------------------

  Future<void> selectInstance(DolibarrInstance instance) async {
    state = AsyncData(instance);

    final prefs = await ref.read(sharedPreferencesProvider.future);

    await prefs.setString('dolibarr_name', instance.name);
    await prefs.setString('dolibarr_baseUrl', instance.baseUrl);
    await prefs.setString('dolibarr_apiKey', instance.apiKey);
  }

  // ------------------------------------------------------------------
  // CLEAR
  // ------------------------------------------------------------------

  Future<void> clear() async {
    state = AsyncData(null);

    final prefs = await ref.read(sharedPreferencesProvider.future);

    await Future.wait([
      prefs.remove('dolibarr_name'),
      prefs.remove('dolibarr_baseUrl'),
      prefs.remove('dolibarr_apiKey'),
    ]);
  }
}
