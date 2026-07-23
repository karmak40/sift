import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../data/models/document.dart';
import '../theme.dart';

class DocIconTile extends StatelessWidget {
  const DocIconTile({super.key, required this.type, this.width = 40, this.height = 46});

  final DocType type;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hue = SiftColors.docTypeHue[type.label] ?? 250;
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: hueColorAlpha(hue, 0.16),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        type.label,
        style: monoStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: hueColor(hue, lightness: 0.4),
        ),
      ),
    );
  }
}

@Preview(name: 'DocIconTile — PDF')
Widget docIconTilePreviewPdf() => const DocIconTile(type: DocType.pdf);

@Preview(name: 'DocIconTile — IMG')
Widget docIconTilePreviewImg() => const DocIconTile(type: DocType.img);

@Preview(name: 'DocIconTile — all types')
Widget docIconTilePreviewAllTypes() => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    for (final type in DocType.values)
      Padding(padding: const EdgeInsets.all(4), child: DocIconTile(type: type)),
  ],
);
