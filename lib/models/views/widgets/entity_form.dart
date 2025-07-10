import 'dart:convert';

import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/json_model.dart';

typedef OnSubmit<T extends JsonModel> = void Function(T entity);
typedef FieldBuilder =
    Widget? Function(
      BuildContext context,
      String key,
      dynamic value,
      TextEditingController? controller,
      void Function(dynamic) onChanged,
      bool expertMode,
    );

class EntityForm<T extends JsonModel> extends ConsumerStatefulWidget {
  final T? initialValue;
  final OnSubmit<T> onSubmit;
  final T Function(Map<String, dynamic>) fromJson;
  final T Function() createEmpty;
  final String? chantierId;
  final FieldBuilder? customFieldBuilder;

  const EntityForm({
    super.key,
    required this.onSubmit,
    required this.fromJson,
    required this.createEmpty,
    this.initialValue,
    this.chantierId,
    this.customFieldBuilder,
  });

  @override
  ConsumerState<EntityForm<T>> createState() => _EntityFormState<T>();
}

class _EntityFormState<T extends JsonModel>
    extends ConsumerState<EntityForm<T>> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _json;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, TextEditingController> _rawOverrides = {};
  bool _expertMode = false;

  @override
  void initState() {
    super.initState();
    final entity = widget.initialValue ?? widget.createEmpty();
    _json = entity.toJson();
    _json['id'] ??= entity.id;

    for (var entry in _json.entries) {
      _controllers[entry.key] = TextEditingController(
        text: entry.value?.toString() ?? '',
      );
      _rawOverrides[entry.key] = TextEditingController(
        text: json.encode(entry.value),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var controller in _rawOverrides.values) {
      controller.dispose();
    }
    super.dispose();
  }

  dynamic _parseValue(dynamic original, String value) {
    if (original is DateTime) return DateTime.tryParse(value);
    if (original is int) return int.tryParse(value);
    if (original is double) return double.tryParse(value);
    if (original is bool) return value.toLowerCase() == 'true';
    if (original is List) return value.split(',').map((e) => e.trim()).toList();
    return value;
  }

  Widget _defaultFieldBuilder({
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
      );
    }

    if (value is Map || value is JsonModel) {
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: "$key (JSON)"),
        style: const TextStyle(fontFamily: 'monospace'),
        maxLines: 4,
      );
    }

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: key),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final updatedJson = <String, dynamic>{};
    for (final key in _json.keys) {
      final originalValue = _json[key];
      final raw = _rawOverrides[key]!.text;

      if (_expertMode &&
          (originalValue is Map ||
              originalValue is List ||
              originalValue is JsonModel)) {
        try {
          updatedJson[key] = json.decode(raw);
        } catch (e) {
          // Fallback
          updatedJson[key] = _parseValue(
            originalValue,
            _controllers[key]!.text,
          );
        }
      } else {
        updatedJson[key] = _parseValue(originalValue, _controllers[key]!.text);
      }
    }

    final entity = widget.fromJson(updatedJson);
    widget.onSubmit(entity);
    Navigator.of(context).pop();
  }

  List<Widget> _buildFields() {
    final fieldBuilder = widget.customFieldBuilder ?? _defaultFieldBuilder;
    final responsive = context.responsiveInfo(ref);

    return _json.keys.map((key) {
      final value = _json[key];
      final controller = _controllers[key];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: fieldBuilder(
          context: context,
          key: key,
          value: value,
          controller: controller,
          onChanged: (val) {
            _json[key] = val;
            _rawOverrides[key]?.text = json.encode(val);
          },
          expertMode: _expertMode,
        ),
      );
    }).toList();
  }

  List<Widget> _buildExpertFields() {
    if (!_expertMode) return [];
    return _json.keys
        .where((key) {
          final val = _json[key];
          return val is Map || val is List || val is JsonModel;
        })
        .map((key) {
          final controller = _rawOverrides[key];
          return TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: "$key (JSON brut)"),
            maxLines: 6,
            style: const TextStyle(fontFamily: 'monospace'),
            validator: (value) {
              try {
                json.decode(value ?? '');
                return null;
              } catch (_) {
                return 'JSON invalide';
              }
            },
          );
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.responsiveInfo(ref).isLandscape;

    return AlertDialog(
      title: Text(
        widget.initialValue == null
            ? "Créer ${T.toString()}"
            : "Modifier ${T.toString()}",
      ),
      content: SizedBox(
        width: isWide ? 600 : double.maxFinite,
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              ..._buildFields(),
              if (_expertMode) ..._buildExpertFields(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _expertMode,
                    onChanged:
                        (val) => setState(() => _expertMode = val ?? false),
                  ),
                  const Text("Mode expert"),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(onPressed: _submit, child: const Text("Valider")),
      ],
    );
  }
}
