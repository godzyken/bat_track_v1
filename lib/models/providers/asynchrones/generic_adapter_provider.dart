import 'package:bat_track_v1/data/core/unified_model.dart';
import 'package:bat_track_v1/data/local/models/adapters/json_adapter.dart';
import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ════════════════════════════════════════════════════════════════════════
/// 🎯 PROVIDERS POUR GenericJsonAdapter
/// ════════════════════════════════════════════════════════════════════════

/// Provider générique pour créer un adapter basique
/// Nécessite d'avoir accès à fromJson et toJson via le type T
Provider<GenericJsonAdapter<T>>
genericJsonAdapterProvider<T extends UnifiedModel>() {
  return Provider<GenericJsonAdapter<T>>((ref) {
    // 🔹 On peut ici créer dynamiquement l'adapter selon T
    return _createAdapterForType<T>(T);
  });
}

/// Fonction helper pour créer un adapter basé sur le type
GenericJsonAdapter<T> _createAdapterForType<T extends UnifiedModel>(Type type) {
  // Map des constructeurs fromJson par type
  final fromJsonMap = <Type, Function>{
    Projet: (Map<String, dynamic> json) => Projet.fromJson(json),
    Chantier: (Map<String, dynamic> json) => Chantier.fromJson(json),
    ChantierEtape: (Map<String, dynamic> json) => ChantierEtape.fromJson(json),
    Intervention: (Map<String, dynamic> json) => Intervention.fromJson(json),
    PieceJointe: (Map<String, dynamic> json) => PieceJointe.fromJson(json),
    Materiel: (Map<String, dynamic> json) => Materiel.fromJson(json),
    Materiau: (Map<String, dynamic> json) => Materiau.fromJson(json),
    MainOeuvre: (Map<String, dynamic> json) => MainOeuvre.fromJson(json),
    AppUser: (Map<String, dynamic> json) => AppUser.fromJson(json),
    Facture: (Map<String, dynamic> json) => Facture.fromJson(json),
    Client: (Map<String, dynamic> json) => Client.fromJson(json),
    Piece: (Map<String, dynamic> json) => Piece.fromJson(json),
    Technicien: (Map<String, dynamic> json) => Technicien.fromJson(json),
  };

  final fromJsonFn = fromJsonMap[type];
  if (fromJsonFn == null) {
    throw UnsupportedError('Type $type non supporté dans GenericJsonAdapter');
  }

  return GenericJsonAdapter<T>(
    fromJsonFn: (json) => fromJsonFn(json) as T,
    toJsonFn: (model) => model.toJson(),
  );
}

/// ════════════════════════════════════════════════════════════════════════
/// 🎯 PROVIDERS SPÉCIFIQUES PAR ENTITÉ
/// ════════════════════════════════════════════════════════════════════════

/// Provider pour Projet
final projetAdapterProvider = Provider<GenericJsonAdapter<Projet>>((ref) {
  return GenericJsonAdapter<Projet>(
    fromJsonFn: Projet.fromJson,
    toJsonFn: (model) => model.toJson(),
    buildFields:
        () => [
          const JsonField(
            name: 'nom',
            label: 'Nom du projet',
            type: FieldType.text,
            icon: Icons.title,
            required: true,
          ),
          const JsonField(
            name: 'description',
            label: 'Description',
            type: FieldType.textarea,
            icon: Icons.description,
          ),
          const JsonField(
            name: 'dateDebut',
            label: 'Date de début',
            type: FieldType.date,
            icon: Icons.calendar_today,
          ),
          const JsonField(
            name: 'dateFin',
            label: 'Date de fin prevue',
            type: FieldType.date,
            icon: Icons.event,
          ),
          const JsonField(
            name: 'deadLine',
            label: 'Date limite',
            type: FieldType.date,
            icon: Icons.calendar_view_month,
          ),
          const JsonField(
            name: 'updatedAt',
            label: 'Updated At',
            type: FieldType.text,
            icon: Icons.calendar_view_day_sharp,
          ),
          const JsonField(
            name: 'createdBy',
            label: 'Created By',
            type: FieldType.text,
            icon: Icons.person,
          ),
          const JsonField(
            name: 'members',
            label: 'Members',
            type: FieldType.multiSelect,
            icon: Icons.person,
          ),
        ],
  );
});

/// Provider pour Chantier
final chantierAdapterProvider = Provider<GenericJsonAdapter<Chantier>>((ref) {
  return GenericJsonAdapter<Chantier>(
    fromJsonFn: Chantier.fromJson,
    toJsonFn: (model) => model.toJson(),
    buildFields:
        () => [
          const JsonField(
            name: 'nom',
            label: 'Nom du chantier',
            type: FieldType.text,
            icon: Icons.construction,
            required: true,
          ),
          const JsonField(
            name: 'adresse',
            label: 'Adresse',
            type: FieldType.text,
            icon: Icons.location_on,
          ),
          const JsonField(
            name: 'projetId',
            label: 'Projet associé',
            type: FieldType.select,
            icon: Icons.link,
          ),
        ],
  );
});

/// Provider pour Intervention
final interventionAdapterProvider = Provider<GenericJsonAdapter<Intervention>>((
  ref,
) {
  return GenericJsonAdapter<Intervention>(
    fromJsonFn: Intervention.fromJson,
    toJsonFn: (model) => model.toJson(),
    buildFields:
        () => [
          const JsonField(
            name: 'titre',
            label: 'Titre',
            type: FieldType.text,
            icon: Icons.work,
            required: true,
          ),
          const JsonField(
            name: 'dateIntervention',
            label: 'Date d\'intervention',
            type: FieldType.date,
            icon: Icons.event,
            required: true,
          ),
          const JsonField(
            name: 'technicienIds',
            label: 'Techniciens',
            type: FieldType.multiSelect,
            icon: Icons.people,
          ),
        ],
  );
});

/// Provider pour AppUser
final userAdapterProvider = Provider<GenericJsonAdapter<AppUser>>((ref) {
  return GenericJsonAdapter<AppUser>(
    fromJsonFn: AppUser.fromJson,
    toJsonFn: (model) => model.toJson(),
    buildFields:
        () => [
          const JsonField(
            name: 'nom',
            label: 'Nom',
            type: FieldType.text,
            icon: Icons.person,
            required: true,
          ),
          const JsonField(
            name: 'email',
            label: 'Email',
            type: FieldType.text,
            icon: Icons.email,
            required: true,
          ),
          const JsonField(
            name: 'role',
            label: 'Rôle',
            type: FieldType.select,
            icon: Icons.badge,
            options: [
              'client',
              'technicien',
              'chefDeProjet',
              'superUtilisateur',
            ],
          ),
        ],
  );
});

/// ════════════════════════════════════════════════════════════════════════
/// 🎯 EXTENSIONS PRATIQUES
/// ════════════════════════════════════════════════════════════════════════

extension JsonAdapterRefExtension on Ref {
  /// Récupère un adapter générique pour un type donné
  GenericJsonAdapter<T> adapterFor<T extends UnifiedModel>() {
    return read(genericJsonAdapterProvider<T>());
  }

  /// Récupère l'adapter pour Projet
  GenericJsonAdapter<Projet> get projetAdapter => read(projetAdapterProvider);

  /// Récupère l'adapter pour Chantier
  GenericJsonAdapter<Chantier> get chantierAdapter =>
      read(chantierAdapterProvider);

  /// Récupère l'adapter pour Intervention
  GenericJsonAdapter<Intervention> get interventionAdapter =>
      read(interventionAdapterProvider);

  /// Récupère l'adapter pour AppUser
  GenericJsonAdapter<AppUser> get userAdapter => read(userAdapterProvider);
}

extension JsonAdapterWidgetRefExtension on WidgetRef {
  /// Récupère un adapter générique pour un type donné
  GenericJsonAdapter<T> adapterFor<T extends UnifiedModel>() {
    return read(genericJsonAdapterProvider<T>());
  }

  /// Récupère l'adapter pour Projet
  GenericJsonAdapter<Projet> get projetAdapter => read(projetAdapterProvider);

  /// Récupère l'adapter pour Chantier
  GenericJsonAdapter<Chantier> get chantierAdapter =>
      read(chantierAdapterProvider);

  /// Récupère l'adapter pour Intervention
  GenericJsonAdapter<Intervention> get interventionAdapter =>
      read(interventionAdapterProvider);

  /// Récupère l'adapter pour AppUser
  GenericJsonAdapter<AppUser> get userAdapter => read(userAdapterProvider);
}

/// ════════════════════════════════════════════════════════════════════════
/// 🎯 HELPER POUR CRÉER DES ADAPTERS PERSONNALISÉS
/// ════════════════════════════════════════════════════════════════════════

/// Factory pour créer facilement un provider d'adapter personnalisé
Provider<GenericJsonAdapter<T>> createAdapterProvider<T extends UnifiedModel>({
  required T Function(Map<String, dynamic>) fromJson,
  required Map<String, dynamic> Function(T) toJson,
  List<JsonField> Function()? buildFields,
  Map<String, dynamic>? initialData,
}) {
  return Provider<GenericJsonAdapter<T>>((ref) {
    return GenericJsonAdapter<T>(
      fromJsonFn: fromJson,
      toJsonFn: toJson,
      buildFields: buildFields,
      initialData: initialData,
    );
  });
}
