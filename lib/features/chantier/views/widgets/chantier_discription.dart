import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/chantier.dart';

class ChantierDescription extends ConsumerWidget {
  const ChantierDescription({
    required this.chantier,
    required this.maxLines,
    required this.overflow,
    super.key,
  });

  final Chantier chantier;
  final int maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      chantier.etapes.map((e) => e.description).join('\n'),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
