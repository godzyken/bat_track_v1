import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

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
  DateTime? fromJson(String? json) =>
      json == null ? null : DateTime.parse(json);

  @override
  String? toJson(DateTime? object) => object?.toIso8601String();
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
