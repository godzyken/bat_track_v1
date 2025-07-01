import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../controllers/providers/chantier_sync_provider.dart';

class ChantierDetailScreen extends ConsumerStatefulWidget {
  final Chantier chantier;
  const ChantierDetailScreen({super.key, required this.chantier});

  @override
  ConsumerState<ChantierDetailScreen> createState() =>
      _ChantierDetailScreenState();
}

class _ChantierDetailScreenState extends ConsumerState<ChantierDetailScreen> {
  late Chantier _chantier;
  final _formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat('dd/MM/yyyy');

  // Contrôleurs uniquement pour budget modifiable
  late TextEditingController _budgetPrevuCtrl;
  late TextEditingController _budgetReelCtrl;

  @override
  void initState() {
    super.initState();
    _chantier = widget.chantier.copyWith(
      etapes: ref.read(etapesTempProvider(widget.chantier.id)),
      documents: [...widget.chantier.documents],
    );

    _budgetPrevuCtrl = TextEditingController(
      text: (_chantier.budgetPrevu ?? 0).toStringAsFixed(2),
    );
    _budgetReelCtrl = TextEditingController(
      text: (_chantier.budgetReel ?? 0).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _budgetPrevuCtrl.dispose();
    _budgetReelCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    _chantier = _chantier.copyWith(
      budgetPrevu: double.tryParse(_budgetPrevuCtrl.text.trim()) ?? 0,
      budgetReel: double.tryParse(_budgetReelCtrl.text.trim()) ?? 0,
    );

    await ref
        .read(chantierSyncProvider(_chantier.id).notifier)
        .update(_chantier);
  }

  Future<void> _showAddEtapeDialog() async {
    final titreCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    DateTime? dateFin;
    bool terminee = false;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Ajouter une étape'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titreCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Titre',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descriptionCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dateFin != null
                                    ? 'Date de fin : ${dateFormat.format(dateFin!)}'
                                    : 'Date de fin non définie',
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: const Text('Choisir'),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    dateFin = picked;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: terminee,
                              onChanged:
                                  (v) => setState(() => terminee = v ?? false),
                            ),
                            const Text('Terminée'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (titreCtrl.text.trim().isEmpty) return;
                        final newEtape = ChantierEtape(
                          titre: titreCtrl.text.trim(),
                          description: descriptionCtrl.text.trim(),
                          terminee: terminee,
                          dateFin: dateFin,
                        );
                        setState(() {
                          _chantier = _chantier.copyWith(
                            etapes: [..._chantier.etapes, newEtape],
                          );
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _pickAndAddDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final docs =
          result.files.map((f) {
            return PieceJointe(
              url: f.path ?? '',
              nom: f.name,
              type: f.extension ?? 'unknown',
              taille: f.size,
              id: '',
            );
          }).toList();

      setState(() {
        _chantier = _chantier.copyWith(
          documents: [..._chantier.documents, ...docs],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bPrevu = _chantier.budgetPrevu ?? 0;
    final bReel = _chantier.budgetReel ?? 0;
    final progress = (bReel / (bPrevu == 0 ? 1 : bPrevu)).clamp(0.0, 2.0);

    return PopScope(
      onPopInvokedWithResult: (bool result, resultCallback) async {
        await _saveChanges();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détails Chantier'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                await _saveChanges();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Modifications sauvegardées')),
                );
              },
              tooltip: 'Sauvegarder',
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('Informations générales'),
              _buildReadOnlyField('Nom', _chantier.nom),
              _buildReadOnlyField('Adresse', _chantier.adresse),
              _buildReadOnlyField('Client', _chantier.clientId),
              _buildReadOnlyField(
                'Date de début',
                dateFormat.format(_chantier.dateDebut),
              ),
              if (_chantier.dateFin != null)
                _buildReadOnlyField(
                  'Date de fin',
                  dateFormat.format(_chantier.dateFin!),
                ),

              const SizedBox(height: 24),

              _buildSectionTitle('Photos & Documents'),
              _buildDocumentsGallery(),

              const SizedBox(height: 24),

              _buildSectionTitle('Étapes'),
              _buildEtapesList(),

              const SizedBox(height: 24),

              _buildSectionTitle('Budget'),
              TextFormField(
                controller: _budgetPrevuCtrl,
                decoration: const InputDecoration(
                  labelText: 'Budget prévu (€)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ requis';
                  if (double.tryParse(v) == null) return 'Valeur invalide';
                  return null;
                },
                onChanged: (v) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _budgetReelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Budget réel (€)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ requis';
                  if (double.tryParse(v) == null) return 'Valeur invalide';
                  return null;
                },
                onChanged: (v) => setState(() {}),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 1 ? Colors.red : Colors.green,
                ),
                minHeight: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  progress > 1
                      ? 'Dépassement budgetaire de ${(bReel - bPrevu).toStringAsFixed(2)} €'
                      : 'Budget utilisé ${(bReel / (bPrevu == 0 ? 1 : bPrevu) * 100).toStringAsFixed(1)} %',
                  style: TextStyle(
                    color: progress > 1 ? Colors.red : Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddEtapeDialog,
          label: const Text('Ajouter étape'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey[800],
        ),
      ),
    );
  }

  Widget _buildDocumentsGallery() {
    if (_chantier.documents.isEmpty) {
      return Column(
        children: [
          const Text('Aucun document pour le moment'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _pickAndAddDocuments,
            icon: const Icon(Icons.upload_file),
            label: const Text('Ajouter des documents'),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _chantier.documents.length,
            itemBuilder: (context, index) {
              final doc = _chantier.documents[index];
              final isImage = [
                'png',
                'jpg',
                'jpeg',
                'gif',
              ].contains(doc.type.toLowerCase());
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () {
                    // TODO: Ouvrir une visionneuse fullscreen
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200,
                          image:
                              isImage
                                  ? DecorationImage(
                                    image: FileImage(File(doc.url)),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            isImage
                                ? null
                                : Center(
                                  child: Icon(
                                    Icons.insert_drive_file_rounded,
                                    size: 48,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 110,
                        child: Text(
                          doc.nom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _pickAndAddDocuments,
          icon: const Icon(Icons.upload_file),
          label: const Text('Ajouter des documents'),
        ),
      ],
    );
  }

  Widget _buildEtapesList() {
    if (_chantier.etapes.isEmpty) {
      return const Text('Aucune étape enregistrée.');
    }

    return Column(
      children:
          _chantier.etapes.asMap().entries.map((entry) {
            final idx = entry.key;
            final etape = entry.value;

            return Card(
              child: ListTile(
                title: Text(etape.titre),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (etape.description.isNotEmpty)
                      Text(
                        etape.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (etape.dateFin != null)
                      Text('Fin prévue : ${dateFormat.format(etape.dateFin!)}'),
                  ],
                ),
                trailing: Checkbox(
                  value: etape.terminee,
                  onChanged: (val) {
                    setState(() {
                      _chantier.etapes[idx] = etape.copyWith(
                        terminee: val ?? false,
                      );
                    });
                  },
                ),
              ),
            );
          }).toList(),
    );
  }
}
