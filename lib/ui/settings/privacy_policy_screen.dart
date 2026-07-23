import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../l10n/app_localizations.dart';
import '../theme.dart';

/// Renders `PRIVACY.md` (bundled as a raw asset — see pubspec.yaml) so the
/// in-app text and the repo's copy can never drift out of sync. Deliberately
/// not run through AppLocalizations: it's legal-ish text, and an
/// auto-translated privacy policy carries more accuracy risk than value —
/// only the surrounding chrome (the page title, the loading/error states)
/// is localized.
///
/// Parsing is a small hand-rolled block-based renderer rather than a full
/// markdown package — PRIVACY.md only ever uses `#`/`##` headings, `-`
/// bullets, and a leading `_italic_` line, so a real markdown dependency
/// would be a lot of package for very little parsing. "Block-based"
/// matters here: PRIVACY.md hard-wraps prose at ~80 columns, so a
/// paragraph or a list item's text is spread across multiple source
/// lines that need joining back into one flowing block, split only on
/// blank lines — not rendered one source line at a time. (There's an
/// equivalent, deliberately-kept-in-sync parser in
/// `tool/build_privacy_page.py`, for the same file published as a public
/// web page via GitHub Pages — see ARCHITECTURE.md §15.)
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicyTitle)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('PRIVACY.md'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.failedToLoad('${snapshot.error}')));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: _renderBlocks(snapshot.data!),
          );
        },
      ),
    );
  }

  List<Widget> _renderBlocks(String markdown) {
    final widgets = <Widget>[];
    var block = <String>[];

    void flush() {
      if (block.isEmpty) return;
      widgets.add(_renderBlock(block));
      widgets.add(const SizedBox(height: 12));
      block = [];
    }

    for (final rawLine in markdown.split('\n')) {
      final line = rawLine.trimRight();
      if (line.isEmpty) {
        flush();
      } else {
        block.add(line);
      }
    }
    flush();
    return widgets;
  }

  Widget _renderBlock(List<String> block) {
    final first = block.first;
    if (first.startsWith('# ')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(first.substring(2), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      );
    }
    if (first.startsWith('## ')) {
      return Text(first.substring(3), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600));
    }
    if (first.startsWith('_') && first.endsWith('_')) {
      return Text(
        first.substring(1, first.length - 1),
        style: TextStyle(fontSize: 12, color: SiftColors.textMuted, fontStyle: FontStyle.italic),
      );
    }
    if (first.startsWith('- ')) {
      // A tight list: each line starting with '- ' begins a new item; any
      // other line in the block is a wrapped continuation of the item
      // immediately above it, joined with a space.
      final items = <String>[];
      for (final line in block) {
        final trimmed = line.trim();
        if (trimmed.startsWith('- ')) {
          items.add(trimmed.substring(2));
        } else {
          items[items.length - 1] = '${items.last} $trimmed';
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(fontSize: 14)),
                  Expanded(child: Text(_stripBold(item), style: const TextStyle(fontSize: 14, height: 1.45))),
                ],
              ),
            ),
        ],
      );
    }
    // Plain paragraph: every line in the block is a wrapped continuation
    // of the same sentence/paragraph — join with a space, not a line break.
    final joined = block.map((l) => l.trim()).join(' ');
    return Text(_stripBold(joined), style: const TextStyle(fontSize: 14, height: 1.45));
  }

  /// Drops `**bold**` markers rather than rendering them — the handful of
  /// bold spans in PRIVACY.md read fine as plain text, and a real inline
  /// span parser is more machinery than this page needs.
  String _stripBold(String text) => text.replaceAll('**', '');
}
