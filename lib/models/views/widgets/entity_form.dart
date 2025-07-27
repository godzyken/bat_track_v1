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
typedef FieldVisibility = bool Function(String key, dynamic value);

class EntityForm<T extends JsonModel> extends ConsumerStatefulWidget {
  final T? initialValue;
  final OnSubmit<T> onSubmit;
  final T Function(Map<String, dynamic>) fromJson;
  final T Function() createEmpty;
  final String? chantierId;
  final FieldBuilder? customFieldBuilder;
  final FieldVisibility? fieldVisibility;

  const EntityForm({
    super.key,
    required this.onSubmit,
    required this.fromJson,
    required this.createEmpty,
    this.initialValue,
    this.chantierId,
    this.customFieldBuilder,
    this.fieldVisibility,
  });

  @override
  ConsumerState<EntityForm<T>> createState() => _EntityFormState<T>();
}

class _EntityFormState<T extends JsonModel>
    extends ConsumerState<EntityForm<T>> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _json;
  final _controllers = <String, TextEditingController>{};
  final _rawOverrides = <String, TextEditingController>{};
  bool _expertMode = false;

  @override
  void initState() {
    super.initState();
    final entity = widget.initialValue ?? widget.createEmpty();
    _json = entity.copyWithId(entity.id)..putIfAbsent('id', () => entity.id);

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
    for (var c in _controllers.values) {
      c.dispose();
    }
    for (var c in _rawOverrides.values) {
      c.dispose();
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

  List<String>? _getAutofillHints(String key) {
    final k = key.toLowerCase();
    if (k.contains('email')) return [AutofillHints.email];
    if (k.contains('name')) return [AutofillHints.name];
    if (k.contains('prenom')) return [AutofillHints.givenName];
    if (k.contains('nom')) return [AutofillHints.familyName];
    if (k.contains('tel')) return [AutofillHints.telephoneNumber];
    if (k.contains('address')) return [AutofillHints.fullStreetAddress];
    if (k.contains('postal')) return [AutofillHints.postalCode];
    if (k.contains('ville')) return [AutofillHints.addressCity];
    if (k.contains('mdp') || k.contains('motdepasse')) {
      return [AutofillHints.newPassword];
    }
    if (k.contains('username') || k.contains('identifiant')) {
      return [AutofillHints.username];
    }
    return null;
  }

  Widget _defaultFieldBuilder({
    required BuildContext context,
    required String key,
    required dynamic value,
    required TextEditingController? controller,
    required void Function(dynamic) onChanged,
    bool expertMode = false,
  }) {
    final autofill = _getAutofillHints(key);
    if (value is bool) {
      return SwitchListTile(
        key: ValueKey(key),
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
        key: ValueKey(key),
        controller: controller,
        readOnly: true,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          labelText: key,
          hintText: 'Entrez votre $key',
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          final initial =
              DateTime.tryParse(controller?.text ?? '') ?? DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller?.text = picked.toIso8601String();
            onChanged(picked);
          }
        },
        autofillHints: autofill,
      );
    }
    if (value is List || key.toLowerCase().contains('liste')) {
      return TextFormField(
        key: ValueKey(key),
        controller: controller,
        decoration: InputDecoration(labelText: "$key (séparés par virgule)"),
        keyboardType: TextInputType.multiline,
        autofillHints: autofill,
      );
    }
    if (value is Map || value is JsonModel) {
      return TextFormField(
        key: ValueKey(key),
        controller: controller,
        decoration: InputDecoration(labelText: "$key (JSON)"),
        style: const TextStyle(fontFamily: 'monospace'),
        maxLines: 4,
        keyboardType: TextInputType.multiline,
        autofillHints: autofill,
      );
    }
    return TextFormField(
      key: ValueKey(key),
      controller: controller,
      decoration: InputDecoration(labelText: key),
      keyboardType: TextInputType.text,
      autofillHints: autofill,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final result = <String, dynamic>{};
    for (final key in _json.keys) {
      final original = _json[key];
      final raw = _rawOverrides[key]!.text;
      result[key] =
          (_expertMode &&
                  (original is Map ||
                      original is List ||
                      original is JsonModel))
              ? json.decode(raw)
              : _parseValue(original, _controllers[key]!.text);
    }
    widget.onSubmit(widget.fromJson(result));
    Navigator.of(context).pop();
  }

  List<Widget> _buildFields() {
    final builder = widget.customFieldBuilder ?? _defaultFieldBuilder;
    return _json.keys.map((key) {
      final val = _json[key];
      final ctl = _controllers[key];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: builder(
          context: context,
          key: key,
          value: val,
          controller: ctl,
          onChanged: (v) {
            _json[key] = v;
            _rawOverrides[key]?.text = json.encode(v);
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
          final ctl = _rawOverrides[key];
          return TextFormField(
            key: ValueKey('expert_$key'),
            controller: ctl,
            decoration: InputDecoration(labelText: "$key (JSON brut)"),
            maxLines: 6,
            style: const TextStyle(fontFamily: 'monospace'),
            validator: (v) {
              try {
                json.decode(v ?? '');
                return null;
              } catch (_) {
                return 'JSON invalide';
              }
            },
            autofillHints: _getAutofillHints(key),
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
            ? 'Créer ${T.toString()}'
            : 'Modifier ${T.toString()}',
      ),
      content: SizedBox(
        width: isWide ? 600 : double.maxFinite,
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              ..._buildFields(),
              ..._buildExpertFields(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _expertMode,
                    onChanged: (v) => setState(() => _expertMode = v ?? false),
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
