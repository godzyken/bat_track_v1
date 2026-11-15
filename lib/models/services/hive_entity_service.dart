import 'package:bat_track_v1/models/services/entity_sync_services.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_models/shared_models.dart';

class HiveEntityService<T extends UnifiedModel>
    implements EntityLocalService<T> {
  final String boxName;
  final T Function(Map<String, dynamic>) fromJson;
  Box<dynamic>? _box;

  HiveEntityService({required this.boxName, required this.fromJson});

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox(boxName);
    } else {
      _box = Hive.box(boxName);
    }
  }

  Map<String, dynamic> _deepConvertMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      final stringKey = key.toString();
      if (value is Map) {
        return MapEntry(stringKey, _deepConvertMap(value));
      } else if (value is List) {
        return MapEntry(
          stringKey,
          value.map((e) => e is Map ? _deepConvertMap(e) : e).toList(),
        );
      }
      return MapEntry(stringKey, value);
    });
  }

  T _parseItem(dynamic item) {
    if (item is T) return item;
    if (item is Map) return fromJson(_deepConvertMap(item));
    throw Exception('Invalid item format in Hive box: $item');
  }

  @override
  Future<List<T>> getAll() async {
    await init();
    return _box!.values.map(_parseItem).toList();
  }

  @override
  Stream<List<T>> watchAll() async* {
    await init();
    yield* _box!.watch().map((_) => _box!.values.map(_parseItem).toList());
  }

  @override
  Future<void> delete(String id) async {
    await init();
    await _box!.delete(id);
  }

  @override
  Future<T?> get(String id) async {
    await init();
    final item = _box!.get(id);
    return item != null ? _parseItem(item) : null;
  }

  @override
  Future<void> put(String id, T item) async {
    await init();
    await _box!.put(id, item.toJson());
  }

  Future<List<T>> getByQuery(Map<String, dynamic> query) async {
    await init();
    return _box!.values
        .map(_parseItem)
        .where(
          (item) => query.entries.every((e) => item.toJson()[e.key] == e.value),
        )
        .toList();
  }

  Stream<List<T>> watchByQuery(Map<String, dynamic> query) {
    return _box!.watch().map(
      (_) => _box!.values
          .map(_parseItem)
          .where(
            (item) =>
                query.entries.every((e) => item.toJson()[e.key] == e.value),
          )
          .toList(),
    );
  }

  Future<T?> getByQueryFirst(Map<String, dynamic> query) async {
    await init();
    final item = _box!.values.firstWhere((item) {
      final parsed = _parseItem(item);
      return query.entries.every((e) => parsed.toJson()[e.key] == e.value);
    }, orElse: () => _handleEntityNotFound());
    return _parseItem(item);
  }

  Future<void> deleteByQuery(Map<String, dynamic> query) async {
    await init();
    final idsToDelete = _box!.keys.where((key) {
      final item = _box!.get(key);
      if (item == null) return false;
      final entity = _parseItem(item);
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

  Future<void> update(T item) async {
    await init();
    await _box!.put(item.id, item.toJson());
  }

  Future<void> create(T item) async {
    await init();
    await _box!.put(item.id, item.toJson());
  }

  Future<void> createBatch(List<T> items) async {
    await init();
    for (final item in items) {
      await _box!.put(item.id, item.toJson());
    }
  }

  Future<void> updateBatch(List<T> items) async {
    await init();
    for (final item in items) {
      await _box!.put(item.id, item.toJson());
    }
  }

  Future<void> deleteBatch(List<T> items) async {
    await init();
    for (final item in items) {
      await _box!.delete(item.id);
    }
  }

  Future<void> deleteByQueryBatch(Map<String, dynamic> query) async {
    await init();
    final idsToDelete = _box!.keys.where((key) {
      final item = _box!.get(key);
      if (item == null) return false;
      final entity = _parseItem(item);
      return query.entries.every((e) => entity.toJson()[e.key] == e.value);
    }).toList();
    for (final id in idsToDelete) {
      await _box!.delete(id);
    }
  }

  Future<void> deleteAllBatch() async {
    await init();
    await _box!.clear();
  }

  Stream<T?> watchById(String id) async* {
    await init();
    yield* _box!.watch(key: id).map((event) {
      final item = _box!.get(id);
      return item != null ? _parseItem(item) : null;
    });
  }

  Future<List<T>> query({
    bool Function(T item)? where,
    int Function(T a, T b)? orderBy,
  }) async {
    await init();
    var results = _box!.values.map(_parseItem).toList();

    if (where != null) {
      results = results.where(where).toList();
    }

    if (orderBy != null) {
      results.sort(orderBy);
    }

    return results;
  }

  Map<String, dynamic> _handleEntityNotFound() {
    throw Exception('Entity not found');
  }
}
