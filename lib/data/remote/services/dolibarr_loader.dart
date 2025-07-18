import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class DolibarrConfig {
  final String baseUrl;
  final String apiKey;

  DolibarrConfig({required this.baseUrl, required this.apiKey});

  factory DolibarrConfig.fromJson(Map<String, dynamic> json) {
    return DolibarrConfig(baseUrl: json['baseUrl'], apiKey: json['apiKey']);
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
        name: json['name'],
        baseUrl: json['baseUrl'],
        apiKey: json['apiKey'],
      );
}

class DolibarrConfigLoader {
  static Future<DolibarrConfig> load() async {
    final jsonStr = await rootBundle.loadString(
      'assets/config/dolibarr_config.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonStr);
    return DolibarrConfig.fromJson(json);
  }

  static Future<List<DolibarrInstance>> loadInstances() async {
    final jsonStr = await rootBundle.loadString(
      'assets/config/dolibarr_config.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonStr);
    return (json['instances'] as List)
        .map((e) => DolibarrInstance.fromJson(e))
        .toList();
  }
}
