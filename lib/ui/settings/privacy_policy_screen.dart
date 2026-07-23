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
/// Parsing is a small hand-rolled line-based renderer rather than a full
/// markdown package — PRIVACY.md only ever uses `#`/`##` headings, `-`
/// bullets, and a leading `_italic_` line, so a real markdown dependency
/// would be a lot of package for very little parsing.
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
            children: _renderLines(snapshot.data!),
          );
        },
      ),
    );
  }

  List<Widget> _renderLines(String markdown) {
    final widgets = <Widget>[];
    for (final rawLine in markdown.split('\n')) {
      final line = rawLine.trimRight();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 12));
      } else if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(line.substring(2), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(line.substring(3), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ));
      } else if (line.startsWith('_') && line.endsWith('_')) {
        widgets.add(Text(
          line.substring(1, line.length - 1),
          style: TextStyle(fontSize: 12, color: SiftColors.textMuted, fontStyle: FontStyle.italic),
        ));
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  ', style: TextStyle(fontSize: 14)),
              Expanded(child: Text(_stripBold(line.substring(2)), style: const TextStyle(fontSize: 14, height: 1.45))),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(_stripBold(line), style: const TextStyle(fontSize: 14, height: 1.45)),
        ));
      }
    }
    return widgets;
  }

  /// Drops `**bold**` markers rather than rendering them — the handful of
  /// bold spans in PRIVACY.md read fine as plain text, and a real inline
  /// span parser is more machinery than this page needs.
  String _stripBold(String text) => text.replaceAll('**', '');
}
