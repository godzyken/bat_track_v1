import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dolibarr_loader.dart';

class DolibarrApiService {
  final Dio dio;

  DolibarrApiService({required String baseUrl, required String token})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

  Future<List<Map<String, dynamic>>> fetch(String endpoint) async {
    final response = await dio.get(endpoint);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      throw Exception(
        'Erreur lors de la récupération des données sur $endpoint',
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchClients() => fetch('/thirdparties');

  Future<List<Map<String, dynamic>>> fetchProducts() => fetch('/products');

  Future<List<Map<String, dynamic>>> fetchInvoices() => fetch('/invoices');

  Future<List<Map<String, dynamic>>> fetchProjects() => fetch('/projects');

  Future<List<Map<String, dynamic>>> fetchChantiers() => fetch('/chantiers');

  Future<List<Map<String, dynamic>>> fetchIntervenants() =>
      fetch('/intervenants');
}

final dolibarrApiServiceProvider =
    Provider.family<DolibarrApiService, DolibarrInstance>((ref, instance) {
      if (instance.name.isEmpty) {
        throw UnimplementedError('DolibarrInstance non configuré');
      }
      return DolibarrApiService(
        baseUrl: instance.baseUrl,
        token: instance.apiKey,
      );
    });
