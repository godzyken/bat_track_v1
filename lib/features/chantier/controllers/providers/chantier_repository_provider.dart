import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository/chantier_repository.dart';

final chantierRepositoryProvider = Provider((ref) => ChantierRepository());
