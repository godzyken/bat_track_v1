import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/views/widgets/entity_form.dart';

class ChantierEtapesScreen extends ConsumerStatefulWidget {
  final String chantierId;
  const ChantierEtapesScreen({super.key, required this.chantierId});

  @override
  ConsumerState<ChantierEtapesScreen> createState() =>
      _ChantierEtapesScreenState();
}

class _ChantierEtapesScreenState extends ConsumerState<ChantierEtapesScreen> {
  List<ChantierEtape> etapes = [];

  void _openForm({ChantierEtape? etape}) async {
    showDialog(
      context: context,
      builder:
          (_) => EntityForm<ChantierEtape>(
            initialValue: etape,
            createEmpty:
                () => ChantierEtape(
                  id: null,
                  titre: '',
                  description: '',
                  dateDebut: DateTime.now(),
                  dateFin: null,
                  terminee: false,
                  chantierId: widget.chantierId,
                ),
            fromJson: (json) => ChantierEtape.fromJson(json),
            chantierId: widget.chantierId,
            onSubmit: (updated) {
              setState(() {
                if (etape == null) {
                  etapes.add(
                    updated.copyWithId(
                      DateTime.now().millisecondsSinceEpoch.toString(),
                    ),
                  );
                } else {
                  final index = etapes.indexWhere((e) => e.id == etape.id);
                  if (index != -1) etapes[index] = updated;
                }
              });
            },
          ),
    );
  }

  void _deleteEtape(ChantierEtape etape) {
    setState(() {
      etapes.removeWhere((e) => e.id == etape.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Étapes du Chantier')),
      body:
          etapes.isEmpty
              ? const Center(child: Text("Aucune étape pour l'instant"))
              : ListView.builder(
                itemCount: etapes.length,
                itemBuilder: (context, index) {
                  final etape = etapes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(etape.titre),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(etape.description),
                          if (etape.dateDebut != null)
                            Text(
                              'Début : ${etape.dateDebut!.toLocal().toString().split(' ')[0]}',
                            ),
                          if (etape.dateFin != null)
                            Text(
                              'Fin : ${etape.dateFin!.toLocal().toString().split(' ')[0]}',
                            ),
                          Text(etape.terminee ? '✅ Terminée' : '⏳ En cours'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _openForm(etape: etape),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteEtape(etape),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text("Nouvelle étape"),
      ),
    );
  }
}
