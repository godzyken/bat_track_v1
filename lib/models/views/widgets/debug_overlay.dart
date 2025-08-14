import 'package:flutter/material.dart';

import '../../data/maperror/debug_config.dart';

class DebugFloatingOverlay extends StatefulWidget {
  const DebugFloatingOverlay({super.key});

  @override
  State<DebugFloatingOverlay> createState() => _DebugFloatingOverlayState();
}

class _DebugFloatingOverlayState extends State<DebugFloatingOverlay> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bouton flottant
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: () {
              setState(() => _isOpen = !_isOpen);
            },
            child: Icon(_isOpen ? Icons.close : Icons.bug_report),
          ),
        ),

        // Panneau des logs
        if (_isOpen)
          Positioned(
            right: 20,
            bottom: 80,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: ValueListenableBuilder<List<DebugLogEntry>>(
                valueListenable: DebugOverlay().logs,
                builder: (context, logs, _) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Logs Debug',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => DebugOverlay().clear(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            return ListTile(
                              title: Text(log.title),
                              subtitle: Text(log.timestamp.toIso8601String()),
                              onTap:
                                  log.json != null
                                      ? () => showDialog(
                                        context: context,
                                        builder:
                                            (_) => AlertDialog(
                                              title: const Text('JSON complet'),
                                              content: SingleChildScrollView(
                                                child: Text(log.json!),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text('Fermer'),
                                                ),
                                              ],
                                            ),
                                      )
                                      : null,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
