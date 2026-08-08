import 'dart:developer' as developer;

import 'package:bat_track_v1/models/data/adapter/safe_async_mixin.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../core/services/unified_entity_service.dart';
import '../../data/local/services/service_type.dart';
import '../data/hive_model.dart';
import '../data/maperror/logged_action.dart';

class SafeAndLoggedEntityService<M extends UnifiedModel, E extends HiveModel<M>>
    extends UnifiedEntityService<M, E>
    with LoggedAction, SafeAsyncMixin<M> {
  final UnifiedEntityService<M, E> _delegate;
  final Ref ref;

  SafeAndLoggedEntityService(this._delegate, this.ref)
    : super(
        collectionName: _delegate.collectionName,
        factory: _delegate.factory,
        remoteStorage: _delegate.remoteStorage,
      ) {
    initLogger(ref);
    initSafeAsync(ref);
  }

  // 1. DÉLÉGATION ET SÉCURITÉ POUR LES MÉTHODES D'ÉCRITURE (Sync)

  @override
  Future<void> save(M entity) async {
    // 💡 Simplification: utilise la signature simplifiée save(T entity)
    await safeVoid(
      () => _delegate.save(entity),
      context: 'save<$M>: ${entity.id}',
    );
    logAction(action: 'save', target: '$M/${entity.id}', data: entity.toJson());
  }

  @override
  Future<void> delete(String id) async {
    await safeVoid(() => _delegate.delete(id), context: 'delete<$M>: $id');
    logAction(action: 'delete', target: '$M/$id');
  }

  // 2. DÉLÉGATION ET SÉCURITÉ POUR LES MÉTHODES DE LECTURE (Fetch)

  // Utiliser getAll() pour les besoins de l'UI (qui fait local/remote/merge)
  @override
  Future<List<M>> getAll() async {
    return await safeAsync<List<M>>(
      () => _delegate.getAllLocal(), // Utilise la méthode hybride getAll()
      context: 'getAll<$M>',
      fallback: [],
    );
  }

  // Utiliser get(id) pour la lecture hybride
  @override
  Future<M?> get(String id) async {
    return await safeAsync<M?>(
      () => _delegate.get(id), // Utilise la méthode hybride get(id)
      context: 'get<$M>:$id',
      fallback: null,
    );
  }

  // 3. DÉLÉGATION DES OPÉRATIONS DE SYNC MANUEL

  @override
  Future<void> syncAllFromRemote() async {
    await safeVoid(
      () => _delegate.syncAllFromRemote(),
      context: 'syncAllFromRemote<$M>',
    );
    logAction(action: 'syncAllFromRemote', target: '$M');
  }

  @override
  Future<void> syncAllToRemote() async {
    await safeVoid(
      () => _delegate.syncAllToRemote(),
      context: 'syncAllToRemote<$M>',
    );
    logAction(action: 'syncAllToRemote', target: '$M');
  }

  // Ces méthodes sont conservées pour la compatibilité si elles sont appelées ailleurs
  Future<void> syncFromRemote({BuildContext? context}) async => syncAllFromRemote();
  Future<void> syncToRemote() async => syncAllToRemote();

  @override
  Stream<List<M>> watchAll() {
    return _delegate.watchAll();
  }

  @override
  Stream<M?> watch(String id) {
    return _delegate.watch(id);
  }

  @override
  Future<List<M>> getRemoteFiltered({
    required dynamic Function(dynamic query) queryBuilder,
  }) async {
    return await safeAsync<List<M>>(
      () => _delegate.getRemoteFiltered(queryBuilder: queryBuilder),
      context: 'getRemoteFiltered<$M>',
      fallback: [],
    );
  }

  @override
  Stream<List<M>> watchRemoteFiltered({
    required dynamic Function(dynamic query) queryBuilder,
  }) {
    return _delegate.watchRemoteFiltered(queryBuilder: queryBuilder);
  }

  @override
  Stream<List<M>> watchByTechnicien(String technicienId) {
    return _delegate.watchByTechnicien(technicienId);
  }

  @override
  Stream<List<M>> watchByOwner(String ownerId) {
    return _delegate.watchByOwner(ownerId);
  }

  @override
  Stream<List<M>> watchByProjects(String projectId) {
    return _delegate.watchByProjects(projectId);
  }

  @override
  Stream<List<M>> watchByOwnerProjects(String ownerId, String projectId) {
    return _delegate.watchByOwnerProjects(ownerId, projectId);
  }

  // 4. DÉLÉGATION AUTOMATIQUE VIA noSuchMethod POUR TOUT LE RESTE

  void _log(String method, List<dynamic> args) {
    developer.log('[LOG][${M.toString()}] $method called with args: $args');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Log du nom et des arguments
    _log(invocation.memberName.toString(), invocation.positionalArguments);

    try {
      // Délégation automatique à _delegate pour toutes les autres méthodes
      return ( _delegate as dynamic).noSuchMethod(invocation);
    } catch (e) {
      if (e is NoSuchMethodError) {
        throw UnimplementedError(
          'Method ${invocation.memberName} not implemented in delegate or decorator.',
        );
      }
      rethrow;
    }
  }
}
