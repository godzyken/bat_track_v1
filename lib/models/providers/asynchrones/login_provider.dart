import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/models/utilisateurs/user.dart';

// provider pour le rôle choisi
final selectedRoleProvider = StateProvider<UserRole?>((ref) => null);

// provider pour l’état de chargement
final loginLoadingProvider = StateProvider<bool>((ref) => false);

// provider pour les erreurs de login
final loginErrorProvider = StateProvider<String?>((ref) => null);

// provider pour éviter de rediriger plusieurs fois
final hasRedirectedProvider = StateProvider<bool>((ref) => false);
