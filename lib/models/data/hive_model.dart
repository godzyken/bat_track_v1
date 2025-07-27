import 'json_model.dart';

abstract class HiveModel<T extends JsonModel> {
  String get id;
  DateTime? get updatedAt;

  T toModel();
  HiveModel<T> fromModel(T model);
}
