import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class ProjectModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Map<String, dynamic> cloudVersion;

  @HiveField(2)
  final Map<String, dynamic>? localDraft;

  ProjectModel({required this.id, required this.cloudVersion, this.localDraft});

  ProjectModel copyWith({
    Map<String, dynamic>? cloudVersion,
    Map<String, dynamic>? localDraft,
  }) {
    return ProjectModel(
      id: id,
      cloudVersion: cloudVersion ?? this.cloudVersion,
      localDraft: localDraft ?? this.localDraft,
    );
  }
}
