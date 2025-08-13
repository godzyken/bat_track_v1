import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/services/remote/remote_storage_service.dart';

class SupabaseService implements RemoteStorageService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupère un enregistrement brut (Map) depuis une table Supabase.
  /// Retourne {} si absent.
  @override
  Future<Map<String, dynamic>> getRaw(String table, String id) async {
    try {
      final res =
          await _supabase.from(table).select().eq('id', id).maybeSingle();

      if (res == null) return {};
      return Map<String, dynamic>.from(res);
    } catch (e, st) {
      developer.log('SupabaseService.getRaw error: $e\n$st');
      rethrow;
    }
  }

  /// Écrit/merge les données dans Supabase (upsert).
  @override
  Future<void> saveRaw(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final toInsert = {...data, 'id': id};
      final res = await _supabase.from(table).upsert(toInsert);
      if (res.error != null) throw res.error!;
    } catch (e, st) {
      developer.log('SupabaseService.saveRaw error: $e\n$st');
      rethrow;
    }
  }

  /// Supprime un enregistrement dans Supabase.
  @override
  Future<void> deleteRaw(String table, String id) async {
    try {
      final res = await _supabase.from(table).delete().eq('id', id);
      if (res.error != null) throw res.error!;
    } catch (e, st) {
      developer.log('SupabaseService.deleteRaw error: $e\n$st');
      rethrow;
    }
  }

  /// Récupère tous les enregistrements (raw),
  /// optionnellement filtrés par updatedAfter et limit.
  @override
  Future<List<Map<String, dynamic>>> getAllRaw(
    String table, {
    DateTime? updatedAfter,
    int? limit,
  }) async {
    try {
      final query = _supabase.from(table).select();

      if (updatedAfter != null) {
        query.gte('updatedAt', updatedAfter.toIso8601String());
      }
      if (limit != null) {
        query.limit(limit);
      }

      final List<dynamic> res = await query;

      return res.map((r) => Map<String, dynamic>.from(r as Map)).toList();
    } catch (e, st) {
      developer.log('SupabaseService.getAllRaw error: $e\n$st');
      rethrow;
    }
  }

  /// Utilité : obtenir des modèles typés directement.
  Future<List<T>> getAll<T>(
    String table,
    T Function(Map<String, dynamic>) fromJson, {
    DateTime? updatedAfter,
    int? limit,
  }) async {
    final raws = await getAllRaw(
      table,
      updatedAfter: updatedAfter,
      limit: limit,
    );
    return raws.map((r) => fromJson(r)).toList();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchCollectionRaw(
    String collectionOrTable, {
    Function(dynamic query)? queryBuilder,
  }) {
    SupabaseQueryBuilder query = _supabase.from(collectionOrTable);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    return query
        .stream(primaryKey: ['id'])
        .map((rows) => rows.map((e) => e).toList());
  }
}

/// Provider global de SupabaseService
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});
