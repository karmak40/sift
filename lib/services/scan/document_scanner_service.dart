import 'dart:io';
import 'dart:typed_data';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'pdf_builder.dart';

/// Opens the OS's native document scanner (ML Kit Document Scanner on
/// Android, VisionKit on iOS) and turns the captured pages into a single
/// PDF via [PdfBuilder].
///
/// Scanning is inherently mobile-only — it needs a camera and native
/// edge-detection. [isSupported] is false on Windows/Web/desktop, and the
/// UI only offers the "Scan" affordance where it's true. The underlying
/// `cunning_document_scanner` package declares only android/ios platforms,
/// so this compiles everywhere but is a no-op off mobile.
class DocumentScannerService {
  const DocumentScannerService(this._pdfBuilder);

  final PdfBuilder _pdfBuilder;

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Returns the assembled PDF's bytes, or null if the user cancelled the
  /// scanner without capturing anything.
  Future<Uint8List?> scanToPdf() async {
    if (!isSupported) return null;

    // Get page images (not the scanner's own PDF) so PDF assembly is
    // identical across Android/iOS and stays in testable Dart — see
    // PdfBuilder's doc comment.
    final paths = await CunningDocumentScanner.getPictures();
    if (paths == null || paths.isEmpty) return null;

    final images = <Uint8List>[];
    for (final path in paths) {
      images.add(await File(path).readAsBytes());
    }
    return _pdfBuilder.imagesToPdf(images);
  }
}
