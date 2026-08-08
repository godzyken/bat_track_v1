import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class DolibarrConfig {
  final String baseUrl;
  final String apiKey;

  DolibarrConfig({required this.baseUrl, required this.apiKey});

  factory DolibarrConfig.fromJson(Map<String, dynamic> json) {
    return DolibarrConfig(
      baseUrl: (json['baseUrl'] as String?) ?? '',
      apiKey: (json['apiKey'] as String?) ?? '',
    );
  }
}

class DolibarrInstance {
  final String name;
  final String baseUrl;
  final String apiKey;

  DolibarrInstance({
    required this.name,
    required this.baseUrl,
    required this.apiKey,
  });

  factory DolibarrInstance.fromJson(Map<String, dynamic> json) =>
      DolibarrInstance(
        name: (json['name'] as String?) ?? '',
        baseUrl: (json['baseUrl'] as String?) ?? '',
        apiKey: (json['apiKey'] as String?) ?? '',
      );
}

class DolibarrConfigLoader {
  static Future<DolibarrConfig> load() async {
    final jsonStr = await rootBundle.loadString(
      'assets/config/dolibarr_config.json',
    );
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;

    return DolibarrConfig.fromJson(json);
  }

  static Future<List<DolibarrInstance>> loadInstances() async {
    final jsonStr = await rootBundle.loadString(
      'assets/config/dolibarr_config.json',
    );
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;

    return (json['instances'] as List)
        .map((e) => DolibarrInstance.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
