import '../../core/unified_model.dart';
import '../models/adapters/json_adapter.dart';

/// 🔧 Registre centralisé des adapters JSON dynamiques
class JsonAdapterRegistry {
  final Map<Type, JsonAdapter<UnifiedModel>> _registry = {};

  /// 🔹 Enregistre un adapter pour un type donné
  void register<T extends UnifiedModel>(JsonAdapter<T> adapter) {
    _registry[T] = adapter as JsonAdapter<UnifiedModel>;
  }

  /// 🔹 Récupère l'adapter correspondant au type `T`
  JsonAdapter<T>? of<T extends UnifiedModel>() {
    final adapter = _registry[T];
    if (adapter == null) return null;
    return adapter as JsonAdapter<T>;
  }

  /// 🔹 Vérifie si un adapter est enregistré
  bool has<T extends UnifiedModel>() => _registry.containsKey(T);

  /// 🔹 Enregistre plusieurs adapters d’un coup
  void registerAll(Map<Type, JsonAdapter<UnifiedModel>> adapters) {
    _registry.addAll(adapters);
  }
}

/// ✅ Instance globale accessible partout
final jsonAdapterRegistry = JsonAdapterRegistry();
