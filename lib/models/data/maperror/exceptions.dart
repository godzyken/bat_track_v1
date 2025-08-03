class EntityNotFoundException implements Exception {
  final String id;
  final Type type;
  EntityNotFoundException(this.type, this.id);

  @override
  String toString() => '[$type] Aucune entité trouvée pour l\'id: $id';
}
