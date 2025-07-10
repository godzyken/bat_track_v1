import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/remote/services/dolibarr_services.dart';

class DolibarrImportScreen extends ConsumerStatefulWidget {
  const DolibarrImportScreen({super.key});

  @override
  ConsumerState<DolibarrImportScreen> createState() =>
      _DolibarrImportScreenState();
}

class _DolibarrImportScreenState extends ConsumerState<DolibarrImportScreen> {
  bool _isLoading = false;
  String _log = '';

  Future<void> _handleImport() async {
    setState(() {
      _isLoading = true;
      _log = 'Démarrage de l’importation...';
    });

    final importer = DolibarrImporter(ref.read(dolibarrApiProvider), ref);

    try {
      await importer.api.fetchAll('s');
      setState(() => _log = '✅ Importation terminée avec succès !');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Importation réussie !')));
      }
    } catch (e) {
      setState(() => _log = '❌ Erreur : $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importation Dolibarr')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleImport,
              icon: const Icon(Icons.download),
              label: const Text('Lancer l’import'),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(_log, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
