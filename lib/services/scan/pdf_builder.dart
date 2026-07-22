import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Assembles a list of page images (JPEG/PNG bytes) into a single PDF, one
/// page per image. Pure Dart — works on every platform and is unit-testable
/// without a camera (see `test/pdf_builder_test.dart`), which matters
/// because the scanner half of this feature (`DocumentScannerService`) needs
/// real device hardware to exercise.
class PdfBuilder {
  const PdfBuilder();

  Future<Uint8List> imagesToPdf(List<Uint8List> images) async {
    if (images.isEmpty) {
      throw ArgumentError('Cannot build a PDF from zero images.');
    }
    final doc = pw.Document();
    for (final bytes in images) {
      final image = pw.MemoryImage(bytes);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ),
      );
    }
    return doc.save();
  }
}
