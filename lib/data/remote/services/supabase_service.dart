import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/services/remote/remote_storage_service.dart';

class SupabaseService extends RemoteStorageService {
  SupabaseService._() : super();
  static final SupabaseService instance = SupabaseService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  bool get isConnected => true;

  @override
  Future<Map<String, dynamic>> getRaw(String table, String id) async {
    try {
      final res = await _supabase
          .from(table)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (res == null) return {};
      return Map<String, dynamic>.from(res as Map<dynamic, dynamic>);
    } catch (e, st) {
      developer.log('SupabaseService.getRaw error: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> saveRaw(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final toInsert = {...data, 'id': id};
      final fromTable = _supabase.from(table);
      await fromTable.upsert(toInsert);
    } catch (e, st) {
      developer.log('SupabaseService.saveRaw error: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> deleteRaw(String table, String id) async {
    try {
      await _supabase.from(table).delete().eq('id', id);
    } catch (e, st) {
      developer.log('SupabaseService.deleteRaw error: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllRaw(
    String table, {
    DateTime? updatedAfter,
    int? limit,
  }) async {
    try {
      dynamic query = _supabase.from(table).select();

      if (updatedAfter != null) {
        query = query.gte('updatedAt', updatedAfter.toIso8601String());
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final res = await query;

      if (res is List) {
        return res
            .map(
              (dynamic r) =>
                  Map<String, dynamic>.from(r as Map<dynamic, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e, st) {
      developer.log('SupabaseService.getAllRaw error: $e\n$st');
      rethrow;
    }
  }

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
    dynamic Function(dynamic query)? queryBuilder,
  }) {
    // Utilisation de dynamic pour contourner les types changeants de Supabase
    dynamic query = _supabase
        .from(collectionOrTable)
        .stream(primaryKey: ['id']);

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    final stream = query as Stream<dynamic>;

    return stream.map((dynamic rows) {
      if (rows is List) {
        return rows
            .map(
              (dynamic e) =>
                  Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            )
            .toList();
      }
      return <Map<String, dynamic>>[];
    });
  }
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});
