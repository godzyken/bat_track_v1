import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../../../data/local/models/index_model_extention.dart';

class EtapeTimeline extends ConsumerWidget {
  final Chantier chantier;
  final ChantierEtape etape;
  final void Function(ChantierEtape selected)? onTap;

  const EtapeTimeline({
    super.key,
    required this.chantier,
    required this.etape,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etapes = chantier.etapes;

    return Timeline.tileBuilder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      theme: TimelineThemeData(
        nodePosition: 0,
        indicatorTheme: const IndicatorThemeData(size: 20),
        connectorTheme: const ConnectorThemeData(thickness: 2.5),
      ),
      builder: TimelineTileBuilder.connected(
        itemCount: etapes.length,
        connectionDirection: ConnectionDirection.before,
        contentsBuilder: (_, index) {
          final current = etapes[index];
          return ListTile(
            title: Text(current.titre),
            subtitle: Text(
              current.dateDebut != null
                  ? 'Début : ${current.dateDebut.toLocal().toString().split(' ').first}'
                  : 'Pas de date',
            ),
            tileColor:
                current.id == etape.id
                    ? Colors.blue.withAlpha(25)
                    : Colors.transparent,
            trailing: Icon(
              current.terminee ? Icons.check_circle : Icons.timelapse,
              color: current.terminee ? Colors.green : Colors.orange,
            ),
            onTap: () => onTap?.call(current),
          );
        },
        indicatorBuilder: (_, index) {
          final e = etapes[index];
          return DotIndicator(
            color: e.terminee ? Colors.green : Colors.grey,
            child:
                e.id == etape.id
                    ? const Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: Colors.white,
                    )
                    : null,
          );
        },
        connectorBuilder: (_, _, _) => const SolidLineConnector(),
      ),
    );
  }
}
