import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/views/widgets/entity_form.dart';
import 'chantier_etape_list_preview.dart';

class ChantierForm extends ConsumerWidget {
  final Chantier? initialValue;
  final void Function(Chantier chantier) onSubmit;

  const ChantierForm({super.key, this.initialValue, required this.onSubmit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EntityForm<Chantier>(
      initialValue: initialValue,
      onSubmit: onSubmit,
      fromJson: Chantier.fromJson,
      createEmpty: Chantier.mock,
      chantierId: initialValue?.id,
      customFieldBuilder: chantierFieldBuilder,
    );
  }
}
