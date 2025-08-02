import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:bat_track_v1/data/local/models/base/import_log.dart';
import 'package:json_annotation/json_annotation.dart';

DateTime? tryParseDate(
  dynamic value, {
  DateTime? fallback,
  String? context,
  ImportLog? log,
}) {
  if (value == null || value.toString().trim().isEmpty) return fallback;
  try {
    return DateTime.parse(value.toString());
  } catch (e) {
    final msg = 'Date invalide "$value"${context != null ? ' ($context)' : ''}';
    if (log != null) {
      log.addWarning(msg);
    } else {
      developer.log('⛔ $msg');
    }
    return fallback;
  }
}

class Uint8ListBase64Converter implements JsonConverter<Uint8List, String> {
  const Uint8ListBase64Converter();

  @override
  Uint8List fromJson(String json) => base64Decode(json);

  @override
  String toJson(Uint8List object) => base64Encode(object);
}

class DateTimeIsoConverter implements JsonConverter<DateTime, String> {
  const DateTimeIsoConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

class NullableDateTimeIsoConverter
    implements JsonConverter<DateTime?, String?> {
  const NullableDateTimeIsoConverter();

  @override
  String? toJson(DateTime? object) => object?.toIso8601String();

  @override
  DateTime? fromJson(dynamic json) {
    return tryParseDate(json);
  }
}

class DurationSecondsConverter implements JsonConverter<Duration, int> {
  const DurationSecondsConverter();

  @override
  Duration fromJson(int json) => Duration(seconds: json);

  @override
  int toJson(Duration object) => object.inSeconds;
}

class NullableDurationSecondsConverter
    implements JsonConverter<Duration?, int?> {
  const NullableDurationSecondsConverter();

  @override
  Duration? fromJson(int? json) =>
      json == null ? null : Duration(seconds: json);

  @override
  int? toJson(Duration? object) => object?.inSeconds;
}

enum EtatChantier { enCours, termine, suspendu }

class EtatChantierConverter implements JsonConverter<EtatChantier, String> {
  const EtatChantierConverter();

  @override
  EtatChantier fromJson(String json) => EtatChantier.values.firstWhere(
    (e) => e.name == json,
    orElse: () => EtatChantier.enCours,
  );

  @override
  String toJson(EtatChantier object) => object.name;
}
