import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/local/models/adapters/json_adapter.dart';

class JsonFormField extends ConsumerStatefulWidget {
  final JsonField field;
  final dynamic value;
  final void Function(dynamic)? onChanged;

  const JsonFormField({
    super.key,
    required this.field,
    required this.value,
    this.onChanged,
  });

  @override
  ConsumerState<JsonFormField> createState() => _JsonFormFieldState();
}

class _JsonFormFieldState extends ConsumerState<JsonFormField> {
  List<String>? _asyncOptions;
  bool _uploading = false;
  double _progress = 0.0;

  Future<void> _loadAsyncOptionsIfNeeded() async {
    if (widget.field.asyncOptions != null) {
      setState(() => _uploading = true);
      final opts = await widget.field.asyncOptions!();
      setState(() {
        _asyncOptions = opts;
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.field.visible) return const SizedBox.shrink();

    switch (widget.field.type) {
      case FieldType.text:
      case FieldType.textarea:
        return _buildTextField();
      case FieldType.number:
        return _buildNumberField();
      case FieldType.date:
        return _buildDatePicker(context);
      case FieldType.select:
        return _buildSelect();
      case FieldType.checkbox:
        return _buildCheckbox();
      case FieldType.switcher:
        return _buildSwitch();
      case FieldType.image:
        return _buildImagePicker(context);
      case FieldType.file:
        return _buildFilePicker(context);
      case FieldType.multiSelect:
        return _buildMultiSelect();
      case FieldType.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
      case FieldType.custom:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Widget _buildTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.field.label,
        border: const OutlineInputBorder(),
      ),
      initialValue: widget.value?.toString() ?? '',
      maxLines: widget.field.type == FieldType.textarea ? 4 : 1,
      onChanged: widget.onChanged,
      validator: widget.field.required
          ? (v) => (v == null || v.isEmpty) ? 'Requis' : null
          : null,
    );
  }

  Widget _buildNumberField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.field.label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      initialValue: widget.value?.toString() ?? '',
      onChanged: (v) => widget.onChanged?.call(double.tryParse(v)),
    );
  }

  Widget _buildSelect() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: widget.field.label,
        border: const OutlineInputBorder(),
      ),
      initialValue: widget.value,
      items: (widget.field.options ?? [])
          .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
          .toList(),
      onChanged: widget.onChanged,
      validator: widget.field.required
          ? (v) => v == null ? 'Requis' : null
          : null,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final date = widget.value is DateTime ? widget.value : null;
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) widget.onChanged?.call(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.field.label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Sélectionner une date',
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return CheckboxListTile(
      title: Text(widget.field.label),
      value: (widget.value ?? false) as bool,
      onChanged: widget.field.readOnly ? null : widget.onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildSwitch() {
    return SwitchListTile(
      title: Text(widget.field.label),
      value: widget.value ?? false,
      onChanged: widget.onChanged != null ? (v) => widget.onChanged!(v) : null,
    );
  }

  // 🖼️ Champ image (caméra / galerie)
  Widget _buildImagePicker(BuildContext context) {
    final imagePath = widget.value?.toString();
    final picker = ImagePicker();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.field.label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        if (imagePath != null)
          Stack(
            children: [
              Image.file(File(imagePath), height: 160, fit: BoxFit.cover),
              Positioned(
                right: 4,
                top: 4,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => widget.onChanged?.call(null),
                  ),
                ),
              ),
            ],
          ),
        if (imagePath == null)
          OutlinedButton.icon(
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Choisir une image'),
            onPressed: () async {
              final source = await showModalBottomSheet<ImageSource>(
                context: context,
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Caméra'),
                        onTap: () => Navigator.pop(ctx, ImageSource.camera),
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Galerie'),
                        onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                      ),
                    ],
                  ),
                ),
              );
              if (source != null) {
                final picked = await picker.pickImage(source: source);
                if (picked != null) widget.onChanged?.call(picked.path);
              }
            },
          ),
      ],
    );
  }

  // 📄 Champ fichier (PDF, DOCX, etc.)
  Widget _buildFilePicker(BuildContext context) {
    final filePath = widget.value?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.field.label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        if (filePath != null)
          Row(
            children: [
              const Icon(Icons.insert_drive_file, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  filePath.split('/').last,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => widget.onChanged?.call(null),
              ),
            ],
          ),
        if (filePath == null)
          OutlinedButton.icon(
            icon: const Icon(Icons.attach_file),
            label: Text(
              _uploading
                  ? 'Téléversement... (${(_progress * 100).round()}%)'
                  : 'Importer un fichier',
            ),
            onPressed: _uploading
                ? null
                : () async {
                    final result = await FilePicker.pickFiles(
                      type: FileType.any,
                    );
                    if (result != null && result.files.single.path != null) {
                      widget.onChanged?.call(result.files.single.path);
                    }
                  },
          ),
      ],
    );
  }

  Widget _buildMultiSelect() {
    final options = _asyncOptions ?? widget.field.options ?? [];
    final selected = (widget.value as List?)?.cast<String>() ?? [];

    return InputDecorator(
      decoration: InputDecoration(labelText: widget.field.label),
      child: Wrap(
        spacing: 6,
        children: options.map((opt) {
          final isSelected = selected.contains(opt);
          return FilterChip(
            label: Text(opt),
            selected: isSelected,
            onSelected: widget.field.readOnly
                ? null
                : (v) {
                    final newList = List<String>.from(selected);
                    if (v) {
                      newList.add(opt);
                    } else {
                      newList.remove(opt);
                    }
                    widget.onChanged?.call(newList);
                  },
          );
        }).toList(),
      ),
    );
  }
}
