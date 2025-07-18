import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../local/providers/shared_preferences_provider.dart';
import '../services/dolibarr_loader.dart';

final dolibarrInstancesProvider = FutureProvider<List<DolibarrInstance>>((
  ref,
) async {
  return await DolibarrConfigLoader.loadInstances();
});

final selectedInstanceProvider =
    StateNotifierProvider<SelectedInstanceNotifier, DolibarrInstance?>((ref) {
      return SelectedInstanceNotifier(ref);
    });

class SelectedInstanceNotifier extends StateNotifier<DolibarrInstance?> {
  final Ref ref;

  SelectedInstanceNotifier(this.ref) : super(null) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final url = prefs.getString('dolibarr_baseUrl');
    final apiKey = prefs.getString('dolibarr_apiKey');
    final name = prefs.getString('dolibarr_name');

    if (url != null && apiKey != null && name != null) {
      state = DolibarrInstance(name: name, baseUrl: url, apiKey: apiKey);
    }
  }

  Future<void> selectInstance(DolibarrInstance instance) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString('dolibarr_name', instance.name);
    await prefs.setString('dolibarr_baseUrl', instance.baseUrl);
    await prefs.setString('dolibarr_apiKey', instance.apiKey);
    state = instance;
  }

  Future<void> clear() async {
    state = null;
    final prefs = await ref.read(sharedPreferencesProvider.future);

    await prefs.remove('selectedInstance');
  }
}
