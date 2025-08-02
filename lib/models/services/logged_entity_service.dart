import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/json_model.dart';
import '../data/maperror/logged_action.dart';
import 'entity_service.dart';

class LoggedEntityService<T extends JsonModel>
    with LoggedAction, Serializable
    implements EntityService<T> {
  final EntityService<T> delegate;

  LoggedEntityService(this.delegate, Ref ref) {
    initLogger(ref);
  }

  @override
  Future<void> save(T entity, String id) async {
    await delegate.save(entity, id);
    logAction(action: 'save', target: '$T/$id', data: entity.toJson());
  }

  @override
  Future<void> update(T entity, String id) async {
    await delegate.update(entity, id);
    logAction(action: 'update', target: '$T/$id', data: entity.toJson());
  }

  @override
  Future<T?> get(String id) async {
    final result = await delegate.get(id);
    logAction(action: 'get', target: '$T/$id', data: result?.toJson());
    return result;
  }

  @override
  T? getById(String id) {
    final result = delegate.getById(id);
    logAction(action: 'getById', target: '$T/$id', data: result?.toJson());
    return result;
  }

  @override
  Future<List<T>> getAll() async {
    final result = await delegate.getAll();
    logAction(
      action: 'getAll',
      target: '$T',
      data: result.map((e) => e.toJson()).toList(),
    );
    return result;
  }

  @override
  Future<List<String>> getKeys() async {
    final keys = await delegate.getKeys();
    logAction(action: 'getKeys', target: '$T', data: {'keys': keys});
    return keys;
  }

  @override
  Future<void> delete(String id) async {
    await delegate.delete(id);
    logAction(action: 'delete', target: '$T/$id');
  }

  @override
  Future<bool> exists(String id) async {
    final result = await delegate.exists(id);
    logAction(action: 'exists', target: '$T/$id', data: {'result': result});
    return result;
  }

  @override
  Future<void> deleteAll() async {
    await delegate.deleteAll();
    logAction(action: 'deleteAll', target: '$T');
  }

  @override
  Future<void> deleteByQuery(String query) async {
    await delegate.deleteByQuery(query);
    logAction(action: 'deleteByQuery', target: '$T', data: {'query': query});
  }

  @override
  Future<List<T>> where(bool Function(T) test) async {
    final result = await delegate.where(test);
    logAction(
      action: 'where',
      target: '$T',
      data: result.map((e) => e.toJson()).toList(),
    );
    return result;
  }

  @override
  Future<List<T>> sortedBy(
    Comparable Function(T) selector, {
    bool descending = false,
  }) async {
    final result = await delegate.sortedBy(selector, descending: descending);
    logAction(
      action: 'sortedBy',
      target: '$T',
      data: result.map((e) => e.toJson()).toList(),
    );
    return result;
  }

  @override
  Future<List<T>> query(String query) async {
    final result = await delegate.query(query);
    logAction(
      action: 'query',
      target: '$T',
      data: result.map((e) => e.toJson()).toList(),
    );
    return result;
  }

  @override
  Future<void> clear() async {
    await delegate.clear();
    logAction(action: 'clear', target: '$T');
  }

  @override
  Future<void> closeAll() async {
    await delegate.closeAll();
    logAction(action: 'closeAll', target: '$T');
  }

  @override
  Future<void> open() async {
    await delegate.open();
    logAction(action: 'open', target: '$T');
  }

  @override
  Future<void> init() async {
    await delegate.init();
    logAction(action: 'init', target: '$T');
  }
}
