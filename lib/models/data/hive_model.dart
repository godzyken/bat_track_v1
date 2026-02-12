import 'package:shared_models/shared_models.dart';

abstract class HiveModel<T extends UnifiedModel> {
  String get id;
  DateTime? get updatedAt;

  T toModel();
  HiveModel<T> fromModel(T model);
}
