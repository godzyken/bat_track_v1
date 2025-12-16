/*
// La classe abstraite EntityNotifier sert de patron.
abstract class EntityNotifier<T extends UnifiedModel>
    extends AsyncNotifier<T?> {
  // Ces champs sont maintenant late, ils seront initialisés dans build().
  late String _id;
  late UnifiedEntityService<T> _service;

  // L'argument 'id' est automatiquement fourni par le .family.
  @override
  Future<T?> build(String id) async {
    // 💡 Récupérer l'argument 'id' via la méthode interne de Riverpod
    // L'argument est la valeur passée à ref.watch(monNotifierFamilyProvider('mon_id'))
    _id =
        ref.keepAlive().argument
            as String; // Assurez-vous d'avoir une façon d'accéder à l'argument 'family'

    // 2. 🛑 ATTENTION: La lecture du service DOIT être surchargée.
    // Lancer une erreur pour forcer le développeur à implémenter la lecture du service spécifique.
    throw UnimplementedError(
      'La lecture du service doit être surchargée dans la classe concrète pour un typage correct.',
    );
  }

  /// Sauvegarde l'entité (Création ou Mise à Jour).
  /// Utilise la méthode sync complète du service unifié.
  Future<void> save(T entity) async {
    // Assurez-vous qu'elle a un ID valide pour la synchro
    final entityToSave =
        entity.id.isEmpty
            ? (entity.copyWithId(const Uuid().v4()) as T)
            : entity;

    // ✅ La seule ligne nécessaire pour persister les données.
    await _service.save(entityToSave);

    // L'état est mis à jour automatiquement par le ref.listen() dans build().
    // Vous pouvez mettre à jour manuellement si vous n'utilisez pas de stream.
    state = AsyncValue.data(entityToSave);
  }

  /// Supprime l'entité (Local + Remote)
  Future<void> delete() async {
    if (state.value == null) return;

    // ✅ La seule ligne nécessaire pour supprimer.
    await _service.delete(_id);

    state = const AsyncValue.data(null);
  }
}
*/
