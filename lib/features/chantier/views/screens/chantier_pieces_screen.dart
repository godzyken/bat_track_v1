import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/data/local/models/base/access_policy_interface.dart';
import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';
import '../../../../models/views/widgets/entity_list.dart';

class ChantierPiecesScreen extends ConsumerWidget {
  final String chantierId;
  const ChantierPiecesScreen({super.key, required this.chantierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final user = ref.watch(currentUserProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isClient = user.role == 'client';
    final isTech = user.role == 'tech';

    final pieceService = ref.watch(pieceServiceProvider);
    final piecesAsync = ref.watch(watchPiecesByChantierProvider(chantierId));

    return Scaffold(
      appBar: AppBar(title: const Text("Pièces du chantier")),
      floatingActionButton:
          isClient
              ? FloatingActionButton(
                onPressed: () {
                  showEntityFormDialog<Piece>(
                    context: context,
                    ref: ref,
                    role: user.role,
                    onSubmit: (piece) async {
                      await pieceService.save(piece);
                    },
                    fromJson: Piece.fromJson,
                    createEmpty: Piece.mock,
                  );
                },
                child: const Icon(Icons.add),
              )
              : null,
      body: EntityList<Piece>(
        items: piecesAsync,
        boxName: 'pieces',
        onCreate:
            isClient
                ? () {
                  showEntityFormDialog<Piece>(
                    context: context,
                    ref: ref,
                    role: user.role,
                    onSubmit: (piece) async {
                      await pieceService.save(piece);
                    },
                    fromJson: Piece.fromJson,
                    createEmpty: Piece.mock,
                  );
                }
                : () {},
        onEdit: (piece) {
          showEntityFormDialog<Piece>(
            context: context,
            ref: ref,
            role: user.role,
            onSubmit: (updated) async {
              await pieceService.save(updated);
            },
            fromJson: Piece.fromJson,
            createEmpty: Piece.mock,
          );
        },
        onDelete: isClient ? (id) => pieceService.delete(id) : null,
        readOnly: !isClient && !isTech,
        currentRole: user.role,
        currentUserId: user.id,
        policy: MultiRolePolicy(),
        infoOverride: info,
      ),
    );
  }
}
