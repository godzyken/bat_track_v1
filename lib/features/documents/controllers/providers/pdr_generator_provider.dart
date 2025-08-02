import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/pdf_generator_service.dart';

final pdfGeneratorProvider = Provider<PdfGeneratorService>((ref) {
  return PdfGeneratorService();
});
