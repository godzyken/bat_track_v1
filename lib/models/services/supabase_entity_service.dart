import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/core/unified_model.dart';
import '../../data/local/services/service_type.dart';

class SupabaseEntityService<T extends UnifiedModel>
    implements EntityServices<T> {
  final String table;
  @override
  final T Function(Map<String, dynamic> json) fromJson;
  final SupabaseClient _supabase = Supabase.instance.client;

  SupabaseEntityService({required this.table, required this.fromJson});

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(table).delete().eq('id', id);
    } catch (e, st) {
      debugPrint("SupabaseEntityService.deleteById error: $e\n$st");
      rethrow;
    }
  }

  @override
  Future<void> deleteByQuery(Map<String, dynamic> query) async {
    if (query.isEmpty) return;
    final fieldName = query.keys.first;
    final value = query[fieldName];
    try {
      await _supabase.from(table).delete().eq(fieldName, value);
    } catch (e, st) {
      debugPrint("SupabaseEntityService.deleteByQuery error: $e\n$st");
      rethrow;
    }
  }

  @override
  Future<List<T>> getAll() async {
    try {
      final data = await _supabase.from(table).select();
      return data
          .map<T>((row) => fromJson(Map<String, dynamic>.from(row)))
          .toList();
    } catch (e, st) {
      debugPrint("SupabaseEntityService.getAll error: $e\n$st");
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
      final query = _supabase.from(table).select();

      if (updatedAfter != null) {
        query.gte('updatedAt', updatedAfter.toIso8601String());
      }
      if (limit != null) {
        query.limit(limit);
      }

      final List<dynamic> result = await query;

      return result
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();
    } catch (e, st) {
      developer.log('SupabaseService.getAllRaw error: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<T?> getById(String id) async {
    try {
      final data =
          await _supabase.from(table).select().eq('id', id).maybeSingle();
      return data != null ? fromJson(Map<String, dynamic>.from(data)) : null;
    } catch (e, st) {
      debugPrint("SupabaseEntityService.getById error: $e\n$st");
      rethrow;
    }
  }

  @override
  Future<void> save(T entity, [String? id]) async {
    try {
      final record = {...entity.toJson(), 'id': id};
      await _supabase.from(table).upsert(record);
    } catch (e, st) {
      debugPrint("SupabaseEntityService.save error: $e\n$st");
      rethrow;
    }
  }

  @override
  Stream<List<T>> watchAll() {
    return _supabase
        .from(table)
        .stream(primaryKey: ['id'])
        .map(
          (rows) =>
              rows
                  .map<T>((row) => fromJson(Map<String, dynamic>.from(row)))
                  .toList(),
        );
  }

  Stream<T?> watchById(String id) {
    return _supabase
        .from(table)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map(
          (rows) =>
              rows.isNotEmpty
                  ? fromJson(Map<String, dynamic>.from(rows.first))
                  : null,
        );
  }

  @override
  Stream<List<T>> watchByChantier(String id) {
    return _supabase
        .from(table)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map(
          (rows) =>
              rows
                  .map((row) => fromJson(Map<String, dynamic>.from(row)))
                  .toList(),
        );
  }

  @override
  Future<void> clear() async {
    try {
      await _supabase.from(table).delete();
    } catch (e, st) {
      debugPrint("SupabaseEntityService.clear error: $e\n$st");
      rethrow;
    }
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
      return Function.apply((_supabase as dynamic).noSuchMethod, [invocation]);
    } catch (_) {
      return super.noSuchMethod(invocation);
    }
  }
}
