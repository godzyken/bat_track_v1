import 'package:bat_track_v1/data/local/models/projets/projet.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UnifiedModel Mixin', () {
    test('parseDateTime should handle various input formats', () {
      // String ISO
      final date1 = UnifiedModel.parseDateTime('2024-01-15T10:30:00.000Z');
      expect(date1, isNotNull);
      expect(date1!.year, 2024);

      // DateTime object
      final now = DateTime.now();
      final date2 = UnifiedModel.parseDateTime(now);
      expect(date2, equals(now));

      // Null input
      final date3 = UnifiedModel.parseDateTime(null);
      expect(date3, isNull);

      // Invalid string
      final date4 = UnifiedModel.parseDateTime('invalid');
      expect(date4, isNull);
    });

    test('parseDateTimeNonNull should throw on null/invalid input', () {
      expect(
        () => UnifiedModel.parseDateTimeNonNull(null),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => UnifiedModel.parseDateTimeNonNull('invalid'),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJsonDateTime should convert DateTime to ISO string', () {
      final date = DateTime(2024, 1, 15, 10, 30);
      final jsonString = UnifiedModel.toJsonDateTime(date);
      expect(jsonString, equals(date.toIso8601String()));

      final nullResult = UnifiedModel.toJsonDateTime(null);
      expect(nullResult, isNull);
    });
  });

  group('JsonModelFactory', () {
    setUp(() {
      // Enregistrer les builders pour les tests
      JsonModelFactory.register<Projet>((json) => Projet.fromJson(json));
    });

    test('should register and retrieve builders correctly', () {
      final testJson = {
        'id': 'test',
        'nom': 'Test Projet',
        'description': '',
        'dateDebut': DateTime.now().toIso8601String(),
        'dateFin': DateTime.now().add(Duration(days: 1)).toIso8601String(),
        'company': 'Test',
        'createdBy': 'test',
        'members': <String>[],
        'assignedUserIds': <String>[],
        'clientValide': false,
        'chefDeProjetValide': false,
        'techniciensValides': false,
        'superUtilisateurValide': false,
        'cloudVersion': {},
        'localDraft': {},
      };

      final projet = JsonModelFactory.fromDynamic<Projet>(testJson);
      expect(projet, isNotNull);
      expect(projet!.nom, 'Test Projet');
    });

    test('should return null for unregistered types', () {
      final result = JsonModelFactory.fromDynamic<String>({'test': 'value'});
      expect(result, isNull);
    });
  });
}
