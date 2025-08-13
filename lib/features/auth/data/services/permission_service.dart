import 'package:pdf/widgets.dart';

import '../../../../data/local/models/base/access_policy_interface.dart';
import '../../../../data/local/models/index_model_extention.dart';

class PermissionService {
  static final Map<Type, AccessPolicy> _policies = {
    Chantier: MultiRolePolicy(),
    ChantierEtape: MultiRolePolicy(),
    Document: MultiRolePolicy(),
    Intervention: MultiRolePolicy(),
    Projet: MultiRolePolicy(),
    Piece: MultiRolePolicy(),
    Materiel: MultiRolePolicy(),
    Materiau: MultiRolePolicy(),
    Equipement: MultiRolePolicy(),
    Facture: MultiRolePolicy(),
  };

  static AccessPolicy forType(Type t) => _policies[t]!;
}
