import '../models/documents/facture_model.dart';
import '../models/entities/facture_model_entity.dart';

extension FactureStatusMapper on FactureStatusEntity {
  FactureStatus toModel() {
    switch (this) {
      case FactureStatusEntity.brouillon:
        return FactureStatus.brouillon;
      case FactureStatusEntity.validee:
        return FactureStatus.validee;
      case FactureStatusEntity.envoyee:
        return FactureStatus.envoyee;
      case FactureStatusEntity.payee:
        return FactureStatus.payee;
    }
  }
}

extension FactureStatusModelMapper on FactureStatus {
  FactureStatusEntity toEntity() {
    switch (this) {
      case FactureStatus.brouillon:
        return FactureStatusEntity.brouillon;
      case FactureStatus.validee:
        return FactureStatusEntity.validee;
      case FactureStatus.envoyee:
        return FactureStatusEntity.envoyee;
      case FactureStatus.payee:
        return FactureStatusEntity.payee;
    }
  }
}
