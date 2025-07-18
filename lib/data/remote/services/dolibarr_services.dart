import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../local/models/index_model_extention.dart';
import '../../local/providers/hive_provider.dart';

class DolibarrApiService {
  final String baseUrl;
  final String token;

  DolibarrApiService({required this.baseUrl, required this.token});

  Future<List<Map<String, dynamic>>> fetchClients() async {
    final response = await http.get(
      Uri.parse('$baseUrl/thirdparties'),
      headers: {'DOLAPIKEY': token},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la récupération des clients');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {'DOLAPIKEY': token},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la récupération des produits');
    }
  }

  Future<List<Map<String, dynamic>>> fetchInvoices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/invoices'),
      headers: {'DOLAPIKEY': token},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la récupération des factures');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects'),
      headers: {'DOLAPIKEY': token},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la récupération des projets');
    }
  }

  Future<void> fetchAll(String s) async {
    await fetchClients();
    await fetchProducts();
    await fetchInvoices();
    await fetchProjects();
  }
}

class DolibarrImporter {
  final DolibarrApiService api;
  final WidgetRef ref;

  DolibarrImporter(this.api, this.ref);

  Future<void> importData() async {
    await _importClients();
    await _importProducts();
    // Tu peux décliner pour invoices, projects, etc.
  }

  Future<void> _importClients() async {
    final clientsJson = await api.fetchClients();
    final clients =
        clientsJson.map<Client>((json) => Client.fromDolibarr(json)).toList();

    final service = ref.read(clientServiceProvider);
    for (final client in clients) {
      await service.save(client, client.id);
    }
  }

  Future<void> _importProducts() async {
    final productsJson = await api.fetchProducts();
    final products =
        productsJson
            .map<Materiau>((json) => Materiau.fromDolibarr(json))
            .toList();

    final service = ref.read(materiauServiceProvider);
    for (final product in products) {
      await service.save(product, product.id);
    }
  }

  // Tu peux décliner pour invoices, projects, etc.
}
