import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../local/providers/shared_preferences_provider.dart';
import '../services/dolibarr_loader.dart';

final dolibarrInstancesProvider = FutureProvider<List<DolibarrInstance>>((
  ref,
) async {
  return DolibarrConfigLoader.loadInstances();
});

final selectedInstanceProvider =
    NotifierProvider<SelectedInstanceNotifier, DolibarrInstance?>(
      SelectedInstanceNotifier.new,
    );

class SelectedInstanceNotifier extends Notifier<DolibarrInstance?> {
  late final Ref _ref;

  @override
  DolibarrInstance? build() {
    _ref = ref;

    // 🔥 side-effect safe via microtask
    Future.microtask(_loadFromPrefs);

    return null;
  }

  // ------------------------------------------------------------------
  // LOAD
  // ------------------------------------------------------------------

  Future<void> _loadFromPrefs() async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);

    final url = prefs.getString('dolibarr_baseUrl');
    final apiKey = prefs.getString('dolibarr_apiKey');
    final name = prefs.getString('dolibarr_name');

    if (url == null || apiKey == null || name == null) return;

    state = DolibarrInstance(name: name, baseUrl: url, apiKey: apiKey);
  }

  // ------------------------------------------------------------------
  // SELECT
  // ------------------------------------------------------------------

  Future<void> selectInstance(DolibarrInstance instance) async {
    state = instance;

    final prefs = await _ref.read(sharedPreferencesProvider.future);

    await prefs.setString('dolibarr_name', instance.name);
    await prefs.setString('dolibarr_baseUrl', instance.baseUrl);
    await prefs.setString('dolibarr_apiKey', instance.apiKey);
  }

  // ------------------------------------------------------------------
  // CLEAR
  // ------------------------------------------------------------------

  Future<void> clear() async {
    state = null;

    final prefs = await _ref.read(sharedPreferencesProvider.future);

    await Future.wait([
      prefs.remove('dolibarr_name'),
      prefs.remove('dolibarr_baseUrl'),
      prefs.remove('dolibarr_apiKey'),
    ]);
  }
}
