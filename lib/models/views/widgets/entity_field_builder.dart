import 'package:flutter/material.dart';

import '../../../data/core/unified_model.dart';

bool isPrimitive(dynamic value) =>
    value is String ||
    value is num ||
    value is bool ||
    value is DateTime ||
    value == null;

dynamic parseValue(dynamic original, String value) {
  if (original is DateTime) return DateTime.tryParse(value);
  if (original is int) return int.tryParse(value);
  if (original is double) return double.tryParse(value);
  if (original is bool) return value.toLowerCase() == 'true';
  if (original is List) return value.split(',').map((e) => e.trim()).toList();
  return value;
}

Widget defaultFieldBuilder({
  required BuildContext context,
  required String key,
  required dynamic value,
  required TextEditingController? controller,
  required void Function(dynamic) onChanged,
  bool expertMode = false,
}) {
  if (value is bool) {
    return SwitchListTile(
      title: Text(key),
      value: controller?.text.toLowerCase() == 'true',
      onChanged: (val) {
        controller?.text = val.toString();
        onChanged(val);
      },
    );
  }

  if (value is DateTime || key.toLowerCase().contains('date')) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      keyboardType: TextInputType.datetime,
      autofillHints: const [AutofillHints.birthday],
      decoration: InputDecoration(
        labelText: key,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final initialDate =
            DateTime.tryParse(controller?.text ?? '') ?? DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          controller?.text = picked.toIso8601String();
          onChanged(picked);
        }
      },
    );
  }

  if (value is List || key.toLowerCase().contains('liste')) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: "$key (séparés par virgule)"),
      keyboardType: TextInputType.multiline,
    );
  }

  if (value is Map || value is UnifiedModel) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: "$key (JSON)"),
      style: const TextStyle(fontFamily: 'NotoSans'),
      maxLines: 4,
      keyboardType: TextInputType.multiline,
    );
  }

  return TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: key),
    keyboardType: TextInputType.multiline,
  );
}
