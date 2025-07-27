import 'package:json_annotation/json_annotation.dart';

import '../models/documents/facture_draft.dart';

class FactureDraftConverter
    implements JsonConverter<FactureDraft?, Map<String, dynamic>?> {
  const FactureDraftConverter();

  @override
  FactureDraft? fromJson(Map<String, dynamic>? json) =>
      json == null ? null : FactureDraft.fromJson(json);

  @override
  Map<String, dynamic>? toJson(FactureDraft? object) => object?.toJson();
}
