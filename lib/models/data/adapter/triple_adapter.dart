import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:shared_models/shared_models.dart';

import '../../../data/remote/providers/dolibarr_instance_provider.dart';

class TripleAdapter<T extends UnifiedModel> {
  final Ref ref;
  final T Function(Map<String, dynamic> json) fromJson;
  final String collectionPath;
  final String dolibarrEndpoint;

  TripleAdapter({
    required this.ref,
    required this.fromJson,
    required this.collectionPath,
    required this.dolibarrEndpoint,
  });

  /// 🔹 Hive
  Future<Box<T>> getHiveBox() async {
    return await Hive.openBox<T>(collectionPath);
  }

  Future<void> saveToHive(T model) async {
    final box = await getHiveBox();
    await box.put(model.id, model);
  }

  /// 🔹 Firebase
  Future<void> saveToFirebase(T model) async {
    final doc = FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(model.id);
    await doc.set(model.toJson(), SetOptions(merge: true));
  }

  Future<List<T>> fetchFromFirebase() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(collectionPath)
        .get();
    return snapshot.docs
        .map((doc) => fromJson({...doc.data(), "id": doc.id}))
        .toList();
  }

  /// 🔹 Dolibarr
  Future<List<T>> fetchFromDolibarr() async {
    final instance = ref.read(selectedInstanceProvider);
    if (instance == null) {
      throw Exception("Aucune instance Dolibarr sélectionnée");
    }

    final url = '${instance.baseUrl}/$dolibarrEndpoint';
    final headers = {'DOLAPIKEY': instance.apiKey};

    final res = await http.get(Uri.parse(url), headers: headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data as List)
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erreur Dolibarr (${res.statusCode}) : ${res.body}');
    }
  }

  Future<void> pushToDolibarr(T model) async {
    final instance = ref.read(selectedInstanceProvider);
    if (instance == null) {
      throw Exception("Aucune instance Dolibarr sélectionnée");
    }

    final url = '${instance.baseUrl}/$dolibarrEndpoint';
    final headers = {
      'DOLAPIKEY': instance.apiKey,
      'Content-Type': 'application/json',
    };

    final res = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(model.toJson()),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(
        'Erreur lors du push Dolibarr: ${res.statusCode} ${res.body}',
      );
    }
  }

  /// 🔹 Import complet Dolibarr → Hive + Firebase
  Future<void> importFromDolibarr() async {
    final items = await fetchFromDolibarr();
    for (final item in items) {
      await saveToHive(item);
      await saveToFirebase(item);
    }
  }
}
