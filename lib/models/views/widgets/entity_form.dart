import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/wrapper/responsive_layout.dart';
import '../../../data/local/models/chantier_etapes.dart';
import '../../data/json_model.dart';
import 'entity_etape_form.dart';

/// Ajout d'un champ optionnel "chantierId" pour lier l'entité au chantier courant.
typedef OnSubmit<T> = void Function(T entity);

class EntityForm<T extends JsonModel> extends ConsumerStatefulWidget {
  final T? initialValue;
  final OnSubmit<T> onSubmit;
  final T Function(Map<String, dynamic>) fromJson;
  final T Function() createEmpty;
  final String? chantierId;

  const EntityForm({
    super.key,
    this.initialValue,
    required this.onSubmit,
    required this.fromJson,
    required this.createEmpty,
    this.chantierId,
  });

  @override
  ConsumerState<EntityForm<T>> createState() => _EntityFormState<T>();
}

class _EntityFormState<T extends JsonModel>
    extends ConsumerState<EntityForm<T>> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, TextEditingController> _rawOverrides = {};
  late Map<String, dynamic> _json;
  bool _expertMode = false;

  List<ChantierEtape> get _etapes {
    final raw = _json['etapes'];
    if (raw is List) {
      // Vérifier le type du premier élément
      if (raw.isEmpty) return [];
      final first = raw.first;

      if (first is ChantierEtape) {
        // C’est déjà la bonne liste
        return List<ChantierEtape>.from(raw);
      } else if (first is Map) {
        // Conversion depuis JSON
        return raw
            .map((e) => ChantierEtape.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    final entity = widget.initialValue ?? widget.createEmpty();
    _json = entity.toJson();

    // Si chantierId fourni mais pas dans le modèle, on l'ajoute
    if (widget.chantierId != null && !_json.containsKey('chantierId')) {
      _json['chantierId'] = widget.chantierId;
    }

    for (var entry in _json.entries) {
      if (_isPrimitive(entry.value)) {
        _controllers[entry.key] = TextEditingController(
          text: entry.value?.toString() ?? '',
        );
      } else {
        _rawOverrides[entry.key] = TextEditingController(
          text: const JsonEncoder.withIndent('  ').convert(entry.value),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    for (var ctrl in _rawOverrides.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final updatedJson = <String, dynamic>{};

    _json.forEach((key, originalValue) {
      if (_controllers.containsKey(key)) {
        updatedJson[key] = _parseValue(key, _controllers[key]!.text);
      } else if (_rawOverrides.containsKey(key)) {
        try {
          updatedJson[key] = json.decode(_rawOverrides[key]!.text);
        } catch (_) {
          updatedJson[key] = originalValue;
        }
      } else {
        updatedJson[key] = originalValue;
      }
    });

    final updatedEntity = widget.fromJson(updatedJson);
    widget.onSubmit(updatedEntity);
    context.pop();
  }

  dynamic _parseValue(String key, String value) {
    final original = _json[key];
    if (original is DateTime) {
      return DateTime.tryParse(value);
    } else if (original is int) {
      return int.tryParse(value);
    } else if (original is double) {
      return double.tryParse(value);
    } else if (original is List) {
      return value.split(',').map((e) => e.trim()).toList();
    } else if (original is bool) {
      return value.toLowerCase() == 'true';
    }
    return value; // default: String
  }

  bool _isPrimitive(dynamic value) =>
      value is String ||
      value is num ||
      value is bool ||
      value is DateTime ||
      value == null;

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final isSmallScreen = screenSize == ScreenSize.mobile;

    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;

    if (_expertMode) {
      for (var entry in _json.entries) {
        if (!_controllers.containsKey(entry.key) &&
            !_rawOverrides.containsKey(entry.key)) {
          _rawOverrides[entry.key] = TextEditingController(
            text: const JsonEncoder.withIndent('  ').convert(entry.value),
          );
        }
      }
    }

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(widget.initialValue == null ? 'Créer' : 'Modifier'),
          ),
          IconButton(
            icon: Icon(_expertMode ? Icons.visibility : Icons.code, size: 20),
            tooltip: _expertMode ? 'Mode normal' : 'Mode expert',
            onPressed: () {
              setState(() {
                _expertMode = !_expertMode;
              });
            },
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: height * (isSmallScreen ? 0.7 : 0.8),
            maxWidth: width * (isSmallScreen ? 0.9 : 0.6),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Wrap(
              runSpacing: 12,
              spacing: 16,
              children: [
                for (var entry in _controllers.entries)
                  SizedBox(
                    width: isSmallScreen ? double.infinity : 250,
                    child:
                        entry.key.toLowerCase().contains('date')
                            ? _buildDateTimeField(entry.key, entry.value)
                            : TextFormField(
                              controller: entry.value,
                              decoration: InputDecoration(labelText: entry.key),
                              validator: (value) {
                                if ((entry.key == 'nom' ||
                                        entry.key == 'titre') &&
                                    (value == null || value.isEmpty)) {
                                  return 'Champ requis';
                                }
                                return null;
                              },
                            ),
                  ),
                if (_json.containsKey('etapes'))
                  SizedBox(
                    width: isSmallScreen ? double.infinity : 500,
                    child: ChantiersEtapeListPreview(
                      etapes: _etapes,
                      onTap: (index) {
                        final id = _json['id'];
                        if (id != null) {
                          context.push('/chantier/$id/etapes/$index');
                        }
                      },
                    ),
                  ),
                if (_expertMode)
                  for (var entry in _rawOverrides.entries)
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 500,
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          labelText: '${entry.key} (JSON)',
                          alignLabelWithHint: true,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 6,
                        style: const TextStyle(fontFamily: 'monospace'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          try {
                            json.decode(value);
                            return null;
                          } catch (e) {
                            return 'Format JSON invalide';
                          }
                        },
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Valider')),
      ],
    );
  }

  Widget _buildDateTimeField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final initialDate =
            DateTime.tryParse(controller.text) ?? DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          controller.text = date.toIso8601String();
        }
      },
    );
  }
}
