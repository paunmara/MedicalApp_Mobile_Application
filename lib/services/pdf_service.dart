import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> exportPage2Pdf({
  required List<Map<String, dynamic>> rows,
  required int year,
  required int month,
  required String generatedAt,
}) async {
  final doc = pw.Document();

  const headers = [
    'Dată', 'Profesie', 'Secție', 'Salon',
    'Apă', 'Săpun', 'Prosop', 'Dezinfectant', 'Pictograme', 'Pregătire Mâini',
  ];

  pw.Widget cell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: isHeader ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
      ),
    );
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Center(
          child: pw.Text(
            'Raport Observații Igiena Mâinilor',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(child: pw.Text('Perioada: $month/$year')),
        pw.Center(child: pw.Text('Generat la: $generatedAt')),
        pw.SizedBox(height: 16),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey700),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue100),
              children: headers.map((h) => cell(h, isHeader: true)).toList(),
            ),
            for (final row in rows)
              pw.TableRow(children: [
                cell(row['date'] as String),
                cell(row['profession'] as String),
                cell(row['section'] as String),
                cell(row['salon'] as String),
                cell(row['apa_curenta'] as String),
                cell(row['sapun_lichid'] as String),
                cell(row['prosop_hartie'] as String),
                cell(row['dezinfectant'] as String),
                cell(row['pictograme'] as String),
                cell(row['pregatire_maini'] as String),
              ]),
          ],
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) => doc.save(),
    name: 'raport_pagina2_${year}_$month.pdf',
  );
}