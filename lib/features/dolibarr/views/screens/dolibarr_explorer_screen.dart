import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../data/remote/providers/dolibarr_instance_provider.dart';
import '../../../../providers/dio_provider.dart';

class DolibarrExplorerScreen extends ConsumerStatefulWidget {
  const DolibarrExplorerScreen({super.key});

  @override
  ConsumerState<DolibarrExplorerScreen> createState() =>
      _DolibarrExplorerScreenState();
}

class _DolibarrExplorerScreenState
    extends ConsumerState<DolibarrExplorerScreen> {
  final TextEditingController _endpointController = TextEditingController(
    text: '/thirdparties',
  );
  final TextEditingController _searchController = TextEditingController();
  AsyncValue<Response>? _response;

  String _filter = '';

  Future<void> _fetchData() async {
    setState(() => _response = const AsyncValue.loading());
    final dio = ref.read(dioProvider);
    final endpoint = _endpointController.text.trim();

    try {
      final res = await dio.get(endpoint);
      setState(() => _response = AsyncValue.data(res));
    } catch (e, st) {
      setState(() => _response = AsyncValue.error(e, st));
    }
  }

  void _copyToClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Réponse copiée dans le presse-papier')),
    );
  }

  Future<void> _exportJsonToFile(String json) async {
    try {
      final dir = await getDownloadsDirectory();
      final file = File(
        '${dir!.path}/dolibarr_export_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(json);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Exporté : ${file.path}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur export : $e')));
      }
    }
  }

  Widget _buildFormattedJson(dynamic data) {
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final lines = LineSplitter.split(jsonString)
        .where((line) => line.toLowerCase().contains(_filter.toLowerCase()))
        .join('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Filtrer...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  setState(() => _filter = val);
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyToClipboard(jsonString),
              tooltip: 'Copier JSON',
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _exportJsonToFile(jsonString),
              tooltip: 'Exporter JSON',
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: SelectableText(
              lines.isEmpty ? 'Aucune correspondance.' : lines,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final instance = ref.watch(selectedInstanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explorateur Dolibarr"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (instance != null)
              Text("Instance : ${instance.name} (${instance.baseUrl})"),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _endpointController,
                    decoration: const InputDecoration(
                      labelText: 'Endpoint Dolibarr',
                      hintText: '/thirdparties',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _fetchData,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text("Charger"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _response == null
                      ? const Center(child: Text("Aucune requête effectuée."))
                      : _response!.when(
                        data: (res) => _buildFormattedJson(res.data),
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                        error: (err, _) => Center(child: Text('Erreur : $err')),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
