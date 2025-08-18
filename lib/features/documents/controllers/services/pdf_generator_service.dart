import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../data/local/models/index_model_extention.dart';

class PdfGeneratorService {
  Future<pw.Document> generatePdfDocument(List<Facture> factures) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Header(level: 0, child: pw.Text('Liste des Factures')),
            pw.ListView.builder(
              itemCount: factures.length,
              itemBuilder: (context, index) {
                final f = factures[index];
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Facture n°: ${f.id}'),
                      pw.Text('Client: ${f.clientId}'),
                      pw.Text('Date: ${f.date.toIso8601String()}'),
                      pw.Text('Montant: ${f.montant} €'),
                      pw.Divider(),
                    ],
                  ),
                );
              },
            ),
          ];
        },
      ),
    );

    return pdf;
  }
}
