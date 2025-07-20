import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/dio_provider.dart';

class DolibarrRequestEditor extends ConsumerStatefulWidget {
  const DolibarrRequestEditor({super.key});

  @override
  ConsumerState<DolibarrRequestEditor> createState() =>
      _DolibarrRequestEditorState();
}

class _DolibarrRequestEditorState extends ConsumerState<DolibarrRequestEditor> {
  String _method = 'GET';
  final _endpointController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _responseText;

  Future<void> _executeRequest() async {
    final dio = ref.read(dioProvider);
    final endpoint = _endpointController.text.trim();
    final method = _method.toUpperCase();
    final bodyRaw = _bodyController.text.trim();

    try {
      late Response res;

      switch (method) {
        case 'GET':
          res = await dio.get(endpoint);
          break;
        case 'POST':
          res = await dio.post(endpoint, data: jsonDecode(bodyRaw));
          break;
        case 'PUT':
          res = await dio.put(endpoint, data: jsonDecode(bodyRaw));
          break;
        case 'DELETE':
          res = await dio.delete(endpoint);
          break;
        default:
          throw Exception("Méthode non supportée");
      }

      setState(() {
        _responseText = const JsonEncoder.withIndent('  ').convert(res.data);
      });
    } catch (e) {
      setState(() {
        _responseText = "Erreur : $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            DropdownButton<String>(
              value: _method,
              items:
                  ['GET', 'POST', 'PUT', 'DELETE']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
              onChanged: (val) => setState(() => _method = val!),
            ),
            SizedBox(
              width: 250,
              child: TextField(
                controller: _endpointController,
                decoration: const InputDecoration(
                  labelText: "Endpoint (ex: thirdparties)",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_method != 'GET' && _method != 'DELETE')
          TextField(
            controller: _bodyController,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: "Corps JSON (POST/PUT)",
              border: OutlineInputBorder(),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.send),
          label: const Text("Exécuter"),
          onPressed: _executeRequest,
        ),
        const SizedBox(height: 16),
        if (_responseText != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(_responseText!),
          ),
      ],
    );
  }
}
