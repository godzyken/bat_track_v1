import 'package:bat_track_v1/models/data/adapter/safe_async_mixin.dart';
import 'package:bat_track_v1/models/data/maperror/fallback_factory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/json_model.dart';
import '../data/maperror/exceptions.dart';
import '../data/maperror/logged_action.dart';
import 'entity_service.dart';

class LoggedEntityService<T extends JsonModel>
    with LoggedAction, SafeAsyncMixin<T>
    implements EntityService<T> {
  final EntityService<T> _delegate;

  LoggedEntityService(this._delegate, Ref ref) {
    initLogger(ref);
    initSafeAsync(ref);
  }

  @override
  @override
  Future<void> save(T entity, String id) async {
    await safeVoid(() => _delegate.save(entity, id), context: 'save<$T>: $id');
    logAction(action: 'save', target: '$T/$id', data: entity.toJson());
  }

  @override
  Future<void> update(T entity, String id) async {
    await safeVoid(
      () => _delegate.update(entity, id),
      context: 'update<$T>/$id',
    );
    logAction(action: 'update', target: '$T/$id', data: entity.toJson());
  }

  @override
  Future<T?> get(String id) async {
    final result = await safeAsync<T>(
      () async => await _delegate.get(id) ?? FallbackFactory.get<T>(),
      context: 'get<$T>/$id',
      logError: true,
      fallback: EntityNotFoundException(T, id) as T,
    );

    logAction(action: 'get', target: '$T/$id', data: result.toJson());
    return result;
  }

  @override
  T? getById(String id) {
    final result = _delegate.getById(id);
    logAction(action: 'getById', target: '$T/$id', data: result?.toJson());
    return result;
  }

  @override
  Future<List<T>> getAll() async {
    return await safeAsync<List<T>>(
      () => _delegate.getAll(),
      context: 'getAll<$T>',
      fallback: [],
    );
  }

  @override
  Future<List<String>> getKeys() async {
    final keys = await safeAsync<List<String>>(
      () => _delegate.getKeys(),
      context: 'getKeys<$T>',
      fallback: FallbackFactory.get<List<String>>(),
    );
    logAction(action: 'getKeys', target: '$T', data: {'keys': keys});
    return keys;
  }

  @override
  Future<void> delete(String id) async {
    await safeAsync(
      () => _delegate.delete(id),
      context: 'delete<$T>: $id',
      fallback: null,
    );
    logAction(action: 'delete', target: '$T/$id');
  }

  @override
  Future<bool> exists(String id) async {
    final result = await safeAsync<bool>(
      () => _delegate.exists(id),
      context: 'exists<$T>/$id',
      fallback: FallbackFactory.get<bool>(),
    );
    logAction(action: 'exists', target: '$T/$id', data: {'result': result});
    return result;
  }

  @override
  Future<void> deleteAll() async {
    await safeVoid(() => _delegate.deleteAll(), context: 'deleteAll<$T>');
    logAction(action: 'deleteAll', target: '$T');
  }

  @override
  Future<void> deleteByQuery(String query) async {
    await safeVoid(
      () => _delegate.deleteByQuery(query),
      context: 'deleteByQuery<$T>',
    );
    logAction(action: 'deleteByQuery', target: '$T/$query');
  }

  @override
  Future<List<T>> where(bool Function(T) test) async {
    final result = await safeAsync<List<T>>(
      () => _delegate.where(test),
      context: 'where<$T>',
      fallback: FallbackFactory.get<List<T>>(),
    );
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
    final result = await safeAsync<List<T>>(
      () => _delegate.sortedBy(selector, descending: descending),
      context: 'sortedBy<$T>',
      fallback: FallbackFactory.get<List<T>>(),
    );
    logAction(
      action: 'sortedBy',
      target: '$T',
      data: result.map((e) => e.toJson()).toList(),
    );
    return result;
  }

  @override
  Future<List<T>> query(String query) async {
    final result = await safeAsync<List<T>>(
      () => _delegate.query(query),
      context: 'query<$T>/$query',
      fallback: FallbackFactory.get<List<T>>(),
    );
    logAction(
      action: 'query',
      target: '$T',
      data: result.map((e) => e.toJson()).toList(),
    );
    return result;
  }

  @override
  Future<void> clear() async {
    await safeVoid(() => _delegate.clear(), context: 'clear<$T>');
    logAction(action: 'clear', target: '$T');
  }

  @override
  Future<void> closeAll() async {
    await safeVoid(() => _delegate.closeAll(), context: 'closeAll<$T>');
    logAction(action: 'closeAll', target: '$T');
  }

  @override
  Future<void> open() async {
    await safeVoid(() => _delegate.open(), context: 'open<$T>');
    logAction(action: 'open', target: '$T');
  }

  @override
  Future<void> init() async {
    await safeVoid(() => _delegate.init(), context: 'init<$T>');
    logAction(action: 'init', target: '$T');
  }
}
