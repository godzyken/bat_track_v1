import 'dart:developer' as developer;

import 'package:bat_track_v1/models/data/adapter/safe_async_mixin.dart';
import 'package:bat_track_v1/models/services/synced_entity_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/services/service_type.dart';
import '../data/json_model.dart';
import '../data/maperror/logged_action.dart';
import 'entity_sync_services.dart';

class LoggedEntityService<T extends JsonModel> implements EntityServices<T> {
  final EntityServices<T> _inner;
  final Ref ref;

  LoggedEntityService(this._inner, this.ref);

  void _log(String method, List<dynamic> args) {
    developer.log('[LOG][${T.toString()}] $method called with args: $args');
  }

  @override
  noSuchMethod(Invocation invocation) {
    // Log du nom et des arguments
    _log(invocation.memberName.toString(), invocation.positionalArguments);

    try {
      // Délégation automatique à _delegate
      return Function.apply((_inner as dynamic).noSuchMethod, [invocation]);
    } catch (_) {
      return super.noSuchMethod(invocation);
    }
  }
}

class LoggedEntitySyncService<T extends JsonModel>
    with LoggedAction, SafeAsyncMixin<T>
    implements SyncedEntityService<T> {
  final SyncedEntityService<T> _delegate;

  LoggedEntitySyncService(this._delegate, Ref ref) {
    initLogger(ref.read);
    initSafeAsync(ref.read);
  }

  @override
  Future<void> save(T entity, [String? id]) async {
    await safeVoid(
      () => _delegate.save(entity, id),
      context: 'save<$T>: ${id ?? entity.id}',
    );
    logAction(
      action: 'save',
      target: '$T/${id ?? entity.id}',
      data: entity.toJson(),
    );
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
  Future<void> delete(String id) async {
    await safeVoid(() => _delegate.delete(id), context: 'delete<$T>: $id');
    logAction(action: 'delete', target: '$T/$id');
  }

  // --- SyncedEntityService extra helpers (local / remote / sync) ---

  @override
  Future<List<T>> getAllFromLocal() async {
    return await safeAsync<List<T>>(
      () => _delegate.getAllFromLocal(),
      context: 'getAllFromLocal<$T>',
      fallback: [],
    );
  }

  @override
  Future<T?> getByIdFromLocal(String id) async {
    return await safeAsync<T?>(
      () => _delegate.getByIdFromLocal(id),
      context: 'getByIdFromLocal<$T>/$id',
      fallback: null,
    );
  }

  @override
  Future<T?> getByIdFromRemote(String id) async {
    return await safeAsync<T?>(
      () => _delegate.getByIdFromRemote(id),
      context: 'getByIdFromRemote<$T>/$id',
      fallback: null,
    );
  }

  @override
  EntityLocalService<T> get local => _delegate.local;

  @override
  EntityRemoteService<T> get remote => _delegate.remote;

  @override
  Future<void> precacheAllWithContext(BuildContext context) async {
    await safeVoid(
      () => _delegate.precacheAllWithContext(context),
      context: 'precacheAllWithContext<$T>',
    );
    logAction(action: 'precacheAllWithContext', target: '$T');
  }

  @override
  Future<void> syncFromRemote({BuildContext? context}) async {
    await safeVoid(
      () => _delegate.syncFromRemote(context: context),
      context: 'syncFromRemote<$T>',
    );
    logAction(action: 'syncFromRemote', target: '$T');
  }

  @override
  Future<void> syncToRemote() async {
    await safeVoid(() => _delegate.syncToRemote(), context: 'syncToRemote<$T>');
    logAction(action: 'syncToRemote', target: '$T');
  }

  @override
  Stream<List<T>> watchAllCombined() {
    // On retourne le stream combiné du delegate mais on logge chaque emission.
    return _delegate.watchAllCombined().map((list) {
      try {
        logAction(
          action: 'watchAllCombined',
          target: '$T',
          data: list.map((e) => e.toJson()).toList(),
        );
      } catch (_) {
        // ne pas throw dans un stream à cause du logging
      }
      return list;
    });
  }

  /// syncEntity est déjà présent dans ta classe précédente et gère SyncableEntityService fallback.
  Future<void> syncEntity(Ref ref, T entity) => _syncEntityWrapper(ref, entity);

  Future<void> _syncEntityWrapper(Ref ref, T entity) async {
    final id = (entity as dynamic).id as String? ?? '';

    await safeVoid(() async {
      if (_delegate is SyncableEntityService<T>) {
        final syncSvc = _delegate as SyncableEntityService<T>;
        final local = await syncSvc.getLocalRaw(id);
        final remote = await syncSvc.getRemoteRaw(id);

        await entity.mergeCloudDataIfAllowed(
          ref,
          getLocalData: () async => local,
          getCloudData: () async => remote,
          saveMergedData: (merged) async {
            await syncSvc.saveRemoteRaw(id, merged);
            await syncSvc.saveLocalRaw(id, merged);
          },
        );

        logAction(
          action: 'syncEntity',
          target: '$T/$id',
          data: {'local': local, 'remote': remote},
        );
        return;
      }

      // FALLBACK
      final maybeLocalEntity =
          await _delegate.getByIdFromLocal(id) ??
          await _delegate.getByIdFromRemote(id);

      final localMap = maybeLocalEntity?.toJson() ?? <String, dynamic>{};

      Map<String, dynamic>? remoteMap;
      try {
        if ((_delegate as dynamic).getRemote != null) {
          remoteMap =
              await (_delegate as dynamic).getRemote(id)
                  as Map<String, dynamic>?;
        } else {
          logAction(
            action: 'syncEntity-fallback-no-remote',
            target: '$T/$id',
            data: {'note': 'no remote access on delegate'},
          );
          return;
        }
      } catch (e) {
        logAction(
          action: 'syncEntity-fallback-remote-error',
          target: '$T/$id',
          data: {'error': e.toString()},
        );
        return;
      }

      final merged = {...(remoteMap ?? {}), ...localMap};

      try {
        final exists = await _delegate.exists(id);
        if (exists) {
          await _delegate.update(maybeLocalEntity ?? entity, id);
        } else {
          await _delegate.save(maybeLocalEntity ?? entity, id);
        }
        logAction(
          action: 'syncEntity-fallback-saved',
          target: '$T/$id',
          data: merged,
        );
      } catch (e) {
        logAction(
          action: 'syncEntity-fallback-save-error',
          target: '$T/$id',
          data: {'error': e.toString()},
        );
      }
    }, context: 'syncEntity<$T>:$id');
  }

  Future<void> updateEntity(T entity, [String? id]) async {
    final entityId = id ?? entity.id;

    await safeVoid(
      () => _delegate.save(entity, entityId),
      context: 'updateEntity<$T>:$entityId',
    );

    logAction(
      action: 'updateEntity',
      target: '$T/$entityId',
      data: entity.toJson(),
    );
  }

  Future<void> updateEntityPartial(
    String id,
    Map<String, dynamic> updates,
  ) async {
    await safeVoid(() async {
      final current =
          await _delegate.getByIdFromLocal(id) ??
          await _delegate.getByIdFromRemote(id);

      if (current == null) {
        throw Exception('Entity <$T> with id=$id not found for update.');
      }

      final updated = current.copyWithJson(updates);
      await _delegate.save(updated, id);
    }, context: 'updateEntityPartial<$T>:$id');

    logAction(action: 'updateEntityPartial', target: '$T/$id', data: updates);
  }

  void _log(String method, List<dynamic> args) {
    developer.log('[LOG][${T.toString()}] $method called with args: $args');
  }

  @override
  noSuchMethod(Invocation invocation) {
    // Log du nom et des arguments
    _log(invocation.memberName.toString(), invocation.positionalArguments);

    try {
      // Délégation automatique à _delegate
      return Function.apply((_delegate as dynamic).noSuchMethod, [invocation]);
    } catch (_) {
      return super.noSuchMethod(invocation);
    }
  }
}

extension<T extends JsonModel> on JsonModel {
  Future<void> mergeCloudDataIfAllowed(
    Ref<Object?> ref, {
    required Future<Map<String, dynamic>> Function() getLocalData,
    required Future<Map<String, dynamic>> Function() getCloudData,
    required Future<Null> Function(dynamic merged) saveMergedData,
  }) async {}
}
