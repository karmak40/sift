import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category.dart';
import '../../data/models/document.dart';
import '../../providers/core_providers.dart';
import '../../services/ai/ai_summary_service.dart';
import '../theme.dart';
import '../widgets/ai_toggle_row.dart';
import '../widgets/doc_icon_tile.dart';

Future<void> showDocumentDetailSheet(
  BuildContext context, {
  required Document document,
  required Category? category,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DocumentDetailSheet(document: document, category: category),
  );
}

class _DocumentDetailSheet extends ConsumerStatefulWidget {
  const _DocumentDetailSheet({required this.document, required this.category});

  final Document document;
  final Category? category;

  @override
  ConsumerState<_DocumentDetailSheet> createState() => _DocumentDetailSheetState();
}

class _DocumentDetailSheetState extends ConsumerState<_DocumentDetailSheet> {
  late Document _doc;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _doc = widget.document;
  }

  Future<void> _toggleAi() async {
    if (_doc.hasAi) {
      await ref.read(documentRepositoryProvider).updateAiSummary(_doc.id, null);
      setState(() => _doc = _doc.copyWith(clearAi: true));
      return;
    }
    await _generate();
  }

  Future<void> _openFile() async {
    final message = await ref.read(fileStorageServiceProvider).openExternally(_doc.storageKey);
    if (message != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      final summary = await ref.read(aiSummaryServiceProvider).summarize(_doc);
      await ref.read(documentRepositoryProvider).updateAiSummary(_doc.id, summary);
      if (!mounted) return;
      setState(() {
        _doc = _doc.copyWith(ai: summary);
        _generating = false;
      });
    } on AiDisabledException {
      if (!mounted) return;
      setState(() => _generating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI summaries are disabled for now.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = _doc;
    final cat = widget.category;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFBFCFD),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: SiftColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DocIconTile(type: doc.type),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              if (cat != null) ...[
                                Text(
                                  cat.name,
                                  style: TextStyle(fontSize: 11, color: SiftColors.textSecondary),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                '${doc.sizeLabel} · added ${_formatDate(doc.addedAt)}',
                                style: monoStyle(fontSize: 10.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(18),
                  children: [
                    Container(
                      height: 110,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: SiftColors.sidebar,
                        border: Border.all(color: SiftColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'document preview · ${doc.type.label}',
                        style: monoStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: SiftColors.accent),
                        const SizedBox(width: 6),
                        Text(
                          'AI SUMMARY',
                          style: monoStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: SiftColors.accentDark,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: doc.hasAi,
                          onChanged: aiFeaturesEnabled && !_generating
                              ? (_) => _toggleAi()
                              : null,
                          activeTrackColor: SiftColors.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_generating)
                      _GeneratingCard(type: doc.type)
                    else if (doc.hasAi)
                      _SummaryCard(summary: doc.ai!)
                    else
                      _NoSummaryCard(
                        onSummarize: aiFeaturesEnabled ? _generate : null,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _openFile,
                        child: const Text('Open file'),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Download'),
                        style: FilledButton.styleFrom(backgroundColor: SiftColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}';
}

class _GeneratingCard extends StatelessWidget {
  const _GeneratingCard({required this.type});
  final DocType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: SiftColors.accentSoft,
        border: Border.all(color: SiftColors.accentSoftBorder),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Reading ${type.label} and extracting key points…',
              style: TextStyle(fontSize: 13, color: SiftColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});
  final dynamic summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SiftColors.accentSoft,
        border: Border.all(color: SiftColors.accentSoftBorder),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.summary as String,
            style: const TextStyle(fontSize: 14, height: 1.5, color: SiftColors.textPrimary),
          ),
          const SizedBox(height: 14),
          Text('KEY POINTS', style: monoStyle(fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(height: 9),
          for (final pt in (summary.points as List))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: SiftColors.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pt as String,
                      style: TextStyle(fontSize: 13, color: SiftColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NoSummaryCard extends StatelessWidget {
  const _NoSummaryCard({required this.onSummarize});
  final VoidCallback? onSummarize;

  @override
  Widget build(BuildContext context) {
    final disabled = onSummarize == null;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: SiftColors.sidebar,
        border: Border.all(color: SiftColors.border, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Text(
            disabled
                ? 'AI summaries are disabled for now. Enable the AI service to let it read this file and pull out key points.'
                : 'No summary yet. Turn on AI to read this file and pull out the important points.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: SiftColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 13),
          FilledButton.icon(
            onPressed: onSummarize,
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Summarize with AI'),
            style: FilledButton.styleFrom(backgroundColor: SiftColors.accent),
          ),
        ],
      ),
    );
  }
}
