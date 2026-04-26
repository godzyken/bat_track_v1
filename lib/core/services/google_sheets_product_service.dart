import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/googleapis_auth.dart';

import '../../../data/local/models/index_model_extention.dart';

/// Service pour synchroniser les produits depuis Google Sheets
class GoogleSheetsProductService {
  final sheets.SheetsApi sheetsApi;
  final String spreadsheetId;

  GoogleSheetsProductService({
    required this.sheetsApi,
    required this.spreadsheetId,
  });

  /// Récupère tous les produits depuis Google Sheets
  Future<List<Produit>> fetchProduits({String range = 'Produits!A2:Z'}) async {
    try {
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        range,
      );

      final values = response.values;
      if (values == null || values.isEmpty) {
        developer.log('📊 Aucune donnée trouvée dans Google Sheets');
        return [];
      }

      final produits = <Produit>[];
      for (var i = 0; i < values.length; i++) {
        try {
          final row = values[i];
          final produit = _parseProduitFromRow(
            row,
            i + 2,
          ); // +2 car ligne 1 = headers, index 0-based
          produits.add(produit);
        } catch (e) {
          developer.log('❌ Erreur parsing ligne ${i + 2}: $e');
        }
      }

      developer.log(
        '✅ ${produits.length} produits importés depuis Google Sheets',
      );
      return produits;
    } catch (e, st) {
      developer.log(
        '❌ Erreur lors de la récupération des produits',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Parse une ligne du Google Sheet en objet Produit
  Produit _parseProduitFromRow(List<dynamic> row, int rowNumber) {
    // Mapping des colonnes (à adapter selon votre structure)
    // A: Référence
    // B: Nom
    // C: Catégorie
    // D: Fabricant
    // E: Description
    // F: Prix unitaire
    // G: Unité
    // H: Taux TVA
    // I: Durée de vie estimée
    // J: Coût maintenance annuel
    // K: Consommation énergétique
    // L: Impact carbone
    // M: Certifications (séparées par ;)
    // N: Normes (séparées par ;)
    // O: Fournisseur

    String? getString(int index) {
      if (index >= row.length) return null;
      final value = row[index];
      return value?.toString().trim().isEmpty == false
          ? value.toString()
          : null;
    }

    double? getDouble(int index) {
      final str = getString(index);
      if (str == null) return null;
      return double.tryParse(str.replaceAll(',', '.'));
    }

    int? getInt(int index) {
      final str = getString(index);
      if (str == null) return null;
      return int.tryParse(str);
    }

    List<String>? getList(int index, {String separator = ';'}) {
      final str = getString(index);
      if (str == null) return null;
      return str
          .split(separator)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final reference = getString(0);
    final id = reference ?? 'sheet_${spreadsheetId}_row_$rowNumber';

    return Produit(
      id: id,
      nom: getString(1) ?? 'Produit sans nom',
      categorie: getString(2) ?? 'Non catégorisé',
      reference: reference,
      fabricant: getString(3),
      description: getString(4),
      prixUnitaire: getDouble(5) ?? 0.0,
      unite: getString(6) ?? 'pièce',
      tauxTVA: getDouble(7) ?? 20.0,
      dureeVieEstimee: getDouble(8),
      coutMaintenanceAnnuel: getDouble(9),
      consommationEnergetique: getDouble(10),
      impactCarbone: getDouble(11),
      certifications: getList(12),
      normes: getList(13),
      fournisseur: getString(14),
      googleSheetsId: spreadsheetId,
      googleSheetsRow: rowNumber,
      createdAt: DateTime.now(),
    );
  }

  /// Ajoute un nouveau produit au Google Sheet
  Future<void> addProduit(Produit produit) async {
    try {
      final row = _produitToRow(produit);

      final valueRange = sheets.ValueRange(values: [row]);

      await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        'Produits!A:O',
        valueInputOption: 'USER_ENTERED',
      );

      developer.log('✅ Produit ajouté au Google Sheet: ${produit.nom}');
    } catch (e, st) {
      developer.log(
        '❌ Erreur lors de l\'ajout du produit',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Convertit un produit en ligne pour Google Sheets
  List<dynamic> _produitToRow(Produit produit) {
    return [
      produit.reference ?? '',
      produit.nom,
      produit.categorie,
      produit.fabricant ?? '',
      produit.description ?? '',
      produit.prixUnitaire,
      produit.unite ?? 'pièce',
      produit.tauxTVA ?? 20.0,
      produit.dureeVieEstimee ?? '',
      produit.coutMaintenanceAnnuel ?? '',
      produit.consommationEnergetique ?? '',
      produit.impactCarbone ?? '',
      produit.certifications?.join(';') ?? '',
      produit.normes?.join(';') ?? '',
      produit.fournisseur ?? '',
    ];
  }

  /// Met à jour un produit existant dans Google Sheets
  Future<void> updateProduit(Produit produit) async {
    if (produit.googleSheetsRow == null) {
      throw Exception('Impossible de mettre à jour: googleSheetsRow manquant');
    }

    try {
      final row = _produitToRow(produit);
      final range =
          'Produits!A${produit.googleSheetsRow}:O${produit.googleSheetsRow}';

      final valueRange = sheets.ValueRange(values: [row]);

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );

      developer.log('✅ Produit mis à jour dans Google Sheet: ${produit.nom}');
    } catch (e, st) {
      developer.log(
        '❌ Erreur lors de la mise à jour du produit',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

/// Provider pour l'authentification Google
final googleAuthProvider = FutureProvider<AutoRefreshingAuthClient>((
  ref,
) async {
  // 1. Chercher le fichier de credentials (injecté par GitHub Actions ou manuellement)
  final envPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];

  if (envPath == null || envPath.isEmpty) {
    throw Exception(
      "Configuration incomplète : GOOGLE_APPLICATION_CREDENTIALS manquant.",
    );
  }

  final credentialsFile = File(envPath);
  final jsonCredentials = await credentialsFile.readAsString();

  // 2. Créer les credentials à partir du JSON temporaire
  final credentials = ServiceAccountCredentials.fromJson(jsonCredentials);

  /*  final credentials = ServiceAccountCredentials(
    'email',
    'projects/55611526582/locations/global/workloadIdentityPools/github-pool/providers/github-provider',
    'github-sheets-sync_@egoteback.iam.gserviceaccount.com',
    githubOidcToken,
    [sheets.SheetsApi.spreadsheetsScope],
  );

  return await clientViaApiKey(credentials, githubOidcToken);*/

  return await clientViaServiceAccount(credentials);
});

/// Provider pour le service Google Sheets
final googleSheetsProductServiceProvider = Provider<GoogleSheetsProductService>(
  (ref) {
    // TODO: Récupérer le spreadsheetId depuis la configuration
    const spreadsheetId = 'YOUR_SPREADSHEET_ID';

    final authAsync = ref.watch(googleAuthProvider);

    return authAsync.when(
      data: (authClient) {
        final sheetsApi = sheets.SheetsApi(authClient);

        return GoogleSheetsProductService(
          sheetsApi: sheetsApi,
          spreadsheetId: spreadsheetId,
        );
      },
      loading: () => throw Exception('Chargement auth Google...'),
      error: (e, st) => throw Exception('Erreur auth Google: $e'),
    );
  },
);
