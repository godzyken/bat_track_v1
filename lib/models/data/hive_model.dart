import '../../data/core/unified_model.dart';

abstract class HiveModel<T extends UnifiedModel> {
  String get id;
  DateTime? get updatedAt;

  T toModel();
  HiveModel<T> fromModel(T model);
}
