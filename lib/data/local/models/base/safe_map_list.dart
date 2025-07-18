List<T> safeMapList<T>(
  dynamic input,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (input == null || input is! List) return [];
  return input
      .whereType<Map<String, dynamic>>()
      .map((e) => fromJson(e))
      .toList();
}
