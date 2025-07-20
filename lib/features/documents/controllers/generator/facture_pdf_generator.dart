import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../data/local/models/index_model_extention.dart';

class FacturePdfGenerator {
  static Future<pw.Document> generate({
    required Chantier chantier,
    required Client? client,
    required FactureDraft facture,
    List<PieceJointe>? piecesJointes,
  }) async {
    final pdf = pw.Document();
    final formatter = DateFormat('dd/MM/yyyy');

    final totalHT = facture.totalHT;
    final tauxTVA = facture.tauxTVA;
    final tva = facture.tvaAmount;
    final totalTTC = facture.totalTTC;

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'FACTURE',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              _buildClientSection(client),
              pw.SizedBox(height: 20),
              _buildChantierSection(chantier),
              pw.SizedBox(height: 20),
              pw.Text(
                'Date de facture : ${formatter.format(facture.dateDerniereModification)}',
              ),
              pw.SizedBox(height: 20),
              _buildLignesFacture(facture),
              pw.SizedBox(height: 12),
              _buildTotaux(totalHT, tauxTVA, tva, totalTTC),
              pw.SizedBox(height: 24),
              if (piecesJointes != null && piecesJointes.isNotEmpty)
                _buildPiecesJointes(piecesJointes),
              if (facture.signature != null)
                _buildSignature(facture.signature!),
            ],
      ),
    );

    return pdf;
  }

  static Future<pw.Document> generateFromIntervention(
    Intervention intervention,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Facture pour l'intervention : ${intervention.titre}"),
                pw.Text("Technicien : ${intervention.technicienId}"),
                pw.Text("Date : ${intervention.date.toIso8601String()}"),
                if (intervention.facture != null) ...[
                  pw.Text("Montant HT : ${intervention.facture!.totalHT}"),
                  pw.Text("Montant TTC : ${intervention.facture!.totalTTC}"),
                  if (intervention.facture!.isFinalized)
                    pw.Text("Facture FINALISÉE"),
                ],
                if ((intervention.document ?? []).isNotEmpty) ...[
                  pw.SizedBox(height: 16),
                  pw.Text("Documents joints :"),
                  ...(intervention.document ?? []).map(
                    (p) => pw.Text("- ${p.nom}"),
                  ),
                ],
              ],
            ),
      ),
    );

    return pdf;
  }

  static pw.Widget _buildClientSection(Client? client) {
    if (client == null) return pw.Container();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Client :',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(client.nom),
        if (client.adresse.isNotEmpty) pw.Text(client.adresse),
        if (client.email.isNotEmpty) pw.Text('Email : ${client.email}'),
        if (client.telephone.isNotEmpty)
          pw.Text('Téléphone : ${client.telephone}'),
      ],
    );
  }

  static pw.Widget _buildChantierSection(Chantier chantier) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Chantier :',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(chantier.nom),
        if (chantier.adresse.isNotEmpty) pw.Text(chantier.adresse),
        if (chantier.commentaire != null)
          pw.Text('Description : ${chantier.commentaire}'),
      ],
    );
  }

  static pw.Widget _buildLignesFacture(FactureDraft facture) {
    return pw.TableHelper.fromTextArray(
      headers: ['Description', 'Montant (€)'],
      data:
          facture.lignesManuelles
              .map(
                (ligne) => [
                  ligne.description,
                  ligne.montant.toStringAsFixed(2),
                ],
              )
              .toList(),
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    );
  }

  static pw.Widget _buildTotaux(
    double totalHT,
    double? tauxTVA,
    double tva,
    double totalTTC,
  ) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('Total HT : ${totalHT.toStringAsFixed(2)} €'),
          if (tauxTVA != null)
            pw.Text(
              'TVA (${tauxTVA.toStringAsFixed(0)}%) : ${tva.toStringAsFixed(2)} €',
            ),
          pw.Text(
            'Total TTC : ${totalTTC.toStringAsFixed(2)} €',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignature(Uint8List signatureBytes) {
    final image = pw.MemoryImage(signatureBytes);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 30),
        pw.Text(
          'Signature du client :',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Image(image, height: 80),
      ],
    );
  }

  static pw.Widget _buildPiecesJointes(List<PieceJointe> pieces) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Pièces jointes associées :',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Bullet(
          text: pieces.map((p) => '${p.nom} (${p.typeMime})').join('\n'),
        ),
      ],
    );
  }
}
