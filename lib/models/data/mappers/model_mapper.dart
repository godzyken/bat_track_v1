import 'package:shared_models/shared_models.dart';

import '../hive_model.dart';

class ModelMapper<H extends HiveModel<T>, T extends UnifiedModel> {
  final H Function() hiveFactory;
  final T Function() modelFactory;

  ModelMapper({required this.hiveFactory, required this.modelFactory});

  H toHive(T model) => hiveFactory().fromModel(model) as H;
  T toModel(H hive) => hive.toModel();
}
