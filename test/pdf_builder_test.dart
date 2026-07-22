import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sift/services/scan/pdf_builder.dart';

/// A real, decodable PNG built at test time — stands in for a scanned page
/// image, so this exercises the actual image-decode + PDF-assembly path.
Uint8List _pngPage() {
  final image = img.Image(width: 16, height: 16);
  img.fill(image, color: img.ColorRgb8(200, 200, 200));
  return img.encodePng(image);
}

void main() {
  const builder = PdfBuilder();

  Uint8List head(Uint8List b, int n) => Uint8List.sublistView(b, 0, n);

  test('produces a real PDF (correct magic header) from one image', () async {
    final pdf = await builder.imagesToPdf([_pngPage()]);

    expect(pdf.length, greaterThan(100));
    // Every PDF starts with "%PDF-".
    expect(utf8.decode(head(pdf, 5)), '%PDF-');
  });

  test('a multi-page scan produces a larger PDF than a single page', () async {
    final page = _pngPage();
    final onePage = await builder.imagesToPdf([page]);
    final threePages = await builder.imagesToPdf([page, page, page]);

    expect(utf8.decode(head(threePages, 5)), '%PDF-');
    expect(threePages.length, greaterThan(onePage.length));
  });

  test('rejects an empty image list rather than emitting a broken PDF', () async {
    expect(() => builder.imagesToPdf([]), throwsArgumentError);
  });
}
