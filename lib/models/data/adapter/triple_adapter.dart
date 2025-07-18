import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../data/remote/providers/dolibarr_instance_provider.dart';
import '../interface/doli_barr_adaptable.dart';
import '../json_model.dart';

class TripleAdapter<T extends JsonModel> {
  final Ref ref;
  final T Function() factory;
  final String collectionPath; // Collection Firebase
  final String dolibarrEndpoint; // Endpoint Dolibarr REST

  TripleAdapter({
    required this.ref,
    required this.factory,
    required this.collectionPath,
    required this.dolibarrEndpoint,
  });

  /// 🔹 Hive: ouvre la box correspondante à T
  Future<Box> getHiveBox() async {
    return await Hive.openBox<T>(collectionPath);
  }

  /// 🔹 Hive: enregistre une instance
  Future<void> saveToHive(Box box, T model) async {
    await box.put(model.id, model);
  }

  /// 🔹 Firebase: envoie une instance
  Future<void> saveToFirebase(T model) async {
    final doc = FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(model.id);
    await doc.set(model.toJson());
  }

  /// 🔹 Firebase: récupère la collection
  Future<List<T>> fetchFromFirebase() async {
    final snapshot =
        await FirebaseFirestore.instance.collection(collectionPath).get();
    return snapshot.docs
        .map((doc) => factory().fromJson({...doc.data(), 'id': doc.id}) as T)
        .toList();
  }

  /// 🔹 Dolibarr: récupère les données via REST
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
          .map(
            (json) =>
                (factory() as DolibarrAdaptable).fromDolibarrJson(json) as T,
          )
          .toList();
    } else {
      throw Exception('Erreur Dolibarr (${res.statusCode}) : ${res.body}');
    }
  }

  /// 🔹 Dolibarr: exporte vers API REST
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

    final body = jsonEncode((model as DolibarrAdaptable).toDolibarrJson());
    final res = await http.post(Uri.parse(url), headers: headers, body: body);

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(
        'Erreur lors du push Dolibarr: ${res.statusCode} ${res.body}',
      );
    }
  }
}
