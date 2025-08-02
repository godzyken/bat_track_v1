import 'dart:developer' as developer;

class ImportLog {
  final List<String> warnings = [];
  final List<String> errors = [];
  final Map<String, int> entityCounts = {};

  void addWarning(String message) => warnings.add(message);

  void addError(String message) => errors.add(message);

  void countEntity(String entity) =>
      entityCounts.update(entity, (v) => v + 1, ifAbsent: () => 1);

  void printSummary() {
    developer.log('\n📦 Résumé de l\'import :');
    entityCounts.forEach((entity, count) {
      developer.log('  ✅ $entity : $count');
    });
    if (warnings.isNotEmpty) {
      developer.log('\n⚠️ Avertissements :');
      for (var w in warnings) {
        developer.log('  - $w');
      }
    }
    if (errors.isNotEmpty) {
      developer.log('\n🛑 Erreurs :');
      for (var e in errors) {
        developer.log('  - $e');
      }
    }
  }
}
