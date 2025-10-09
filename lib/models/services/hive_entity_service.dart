import 'package:bat_track_v1/data/core/unified_model.dart';
import 'package:bat_track_v1/models/services/entity_sync_services.dart';
import 'package:hive/hive.dart';

class HiveEntityService<T extends UnifiedModel>
    implements EntityLocalService<T> {
  final String boxName;
  final T Function(Map<String, dynamic>) fromJson;
  Box<Map>? _box;

  HiveEntityService({required this.boxName, required this.fromJson});

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox<Map>(boxName);
    } else {
      _box = Hive.box<Map>(boxName);
    }
  }

  @override
  Future<List<T>> getAll() async {
    await init();
    return _box!.values
        .map((json) => fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Stream<List<T>> watchAll() {
    return _box!.watch().map(
      (_) =>
          _box!.values
              .map((json) => fromJson(Map<String, dynamic>.from(json)))
              .toList(),
    );
  }

  @override
  Future<void> delete(String id) async {
    await init();
    await _box!.delete(id);
  }

  @override
  Future<T?> get(String id) async {
    final json = _box!.get(id);
    return json != null ? fromJson(Map<String, dynamic>.from(json)) : null;
  }

  @override
  Future<void> put(String id, T item) async {
    await init();
    await _box!.put(id, item.toJson());
  }

  Future<List<T>> getByQuery(Map<String, dynamic> query) async {
    await init();
    return _box!.values
        .map((json) => fromJson(Map<String, dynamic>.from(json)))
        .where(
          (item) => query.entries.every((e) => item.toJson()[e.key] == e.value),
        )
        .toList();
  }

  Stream<List<T>> watchByQuery(Map<String, dynamic> query) {
    return _box!.watch().map(
      (_) =>
          _box!.values
              .map((json) => fromJson(Map<String, dynamic>.from(json)))
              .where(
                (item) =>
                    query.entries.every((e) => item.toJson()[e.key] == e.value),
              )
              .toList(),
    );
  }

  Future<void> deleteByQuery(Map<String, dynamic> query) async {
    final idsToDelete =
        _box!.keys.where((key) {
          final json = _box!.get(key);
          if (json == null) return false;
          final entity = fromJson(Map<String, dynamic>.from(json));
          return query.entries.every((e) => entity.toJson()[e.key] == e.value);
        }).toList();
    for (final id in idsToDelete) {
      await _box!.delete(id);
    }
  }

  Future<void> deleteAll() async {
    await init();
    await _box!.clear();
  }
}
