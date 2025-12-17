import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Cette ligne est nécessaire pour la génération de code
class SelectedRoleNotifier extends Notifier<UserRole?> {
  @override
  UserRole build() {
    // Valeur par défaut (par exemple technicien, ou le premier de la liste)
    return UserRole.values.first;
  }

  // Met à jour l'état avec le rôle passé en paramètre
  void setRole(UserRole role) {
    state = role;
  }

  // Si vous recevez un String (depuis un menu déroulant par ex) et devez le convertir
  void setRoleFromString(String? roleName) {
    if (roleName == null) return;

    try {
      // Trouve l'enum qui correspond au nom (ex: "technicien" -> UserRole.technicien)
      final role = UserRole.values.firstWhere(
        (e) => e.name == roleName, // ou e.toString() selon votre modèle
        orElse: () => state!, // Garde l'état actuel si non trouvé
      );
      state = role;
    } catch (_) {
      // Gérer l'erreur si nécessaire
    }
  }
}

// Exemple pour les autres notifiers convertis au format Riverpod 3

class LoginLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false; // État initial à false

  void setLoading(bool isLoading) {
    state = isLoading;
  }
}

class LoginErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null; // Pas d'erreur au départ

  void setError(String? message) {
    state = message;
  }
}

class HasRedirectedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setRedirected(bool value) {
    state = value;
  }
}
