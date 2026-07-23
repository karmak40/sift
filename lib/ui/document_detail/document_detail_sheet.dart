import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/category.dart';
import '../../data/models/document.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../providers/data_providers.dart';
import '../../providers/document_actions.dart';
import '../../services/ai/ai_summary_service.dart';
import '../move/move_to_sheet.dart';
import '../theme.dart';
import '../widgets/ai_toggle_row.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/doc_icon_tile.dart';

const _reminderLeadOptions = [7, 14, 30, 60, 90];

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

  Future<void> _shareDocument() async {
    final l10n = AppLocalizations.of(context)!;
    if (_doc.storageKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noFileAttached)),
      );
      return;
    }
    final bytes = await ref.read(fileStorageServiceProvider).read(_doc.storageKey);
    if (!mounted) return;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fileMissingFromDisk)),
      );
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, name: _doc.name, mimeType: _doc.type.mimeType)],
        fileNameOverrides: [_doc.name],
      ),
    );
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteDocumentConfirmTitle(_doc.name),
      message: l10n.deleteDocumentConfirmMessage,
    );
    if (!confirmed) return;
    await deleteDocumentsWithRef(ref, [_doc]);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _rename() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _doc.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.renameDocumentTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == _doc.name) return;
    await ref.read(documentRepositoryProvider).rename(_doc.id, newName);
    if (mounted) setState(() => _doc = _doc.copyWith(name: newName));
  }

  Future<void> _changeCategory(List<Category> categories) async {
    await showMoveToSheet(
      context,
      documentIds: [_doc.id],
      categories: categories,
      onMoved: (categoryId) {
        if (mounted) setState(() => _doc = _doc.copyWith(categoryId: categoryId));
      },
    );
  }

  Future<void> _pickExpirationDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _doc.expiresAt ?? DateTime(now.year, now.month, now.day + 30),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 50),
    );
    if (picked == null) return;
    final updated = await setDocumentExpirationWithRef(ref, _doc, expiresAt: picked);
    if (mounted) setState(() => _doc = updated);
  }

  Future<void> _changeReminderLead() async {
    final choice = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ReminderLeadSheet(),
    );
    if (choice == null) return;
    final updated = await setDocumentExpirationWithRef(
      ref,
      _doc,
      expiresAt: _doc.expiresAt,
      reminderDaysBefore: choice,
    );
    if (mounted) setState(() => _doc = updated);
  }

  Future<void> _clearExpiration() async {
    final updated = await setDocumentExpirationWithRef(ref, _doc, expiresAt: null);
    if (mounted) setState(() => _doc = updated);
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
        SnackBar(content: Text(AppLocalizations.of(context)!.aiDisabledSnackbar)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final doc = _doc;
    final categories = ref.watch(categoriesProvider).valueOrNull;
    final cat = categories == null
        ? widget.category
        : categories.cast<Category?>().firstWhere((c) => c!.id == doc.categoryId, orElse: () => null);
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
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              InkWell(
                                onTap: () => _changeCategory(categories ?? const []),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        cat?.name ?? l10n.uncategorized,
                                        style: TextStyle(fontSize: 11, color: SiftColors.accentDark, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(Icons.unfold_more, size: 12, color: SiftColors.accentDark),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.sizeAddedOn(doc.sizeLabel, _formatDate(doc.addedAt)),
                                style: monoStyle(fontSize: 10.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: SiftColors.textSecondary),
                      tooltip: l10n.renameDocumentTitle,
                      onPressed: _rename,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: SiftColors.danger),
                      tooltip: l10n.deleteDocumentTooltip,
                      onPressed: _delete,
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
                        l10n.documentPreviewLabel(doc.type.label),
                        style: monoStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ExpirationSection(
                      document: doc,
                      onSetDate: _pickExpirationDate,
                      onChangeReminder: _changeReminderLead,
                      onClear: _clearExpiration,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: SiftColors.accent),
                        const SizedBox(width: 6),
                        Text(
                          l10n.aiSummaryLabel,
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
                        child: Text(l10n.openFile),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _shareDocument,
                        icon: const Icon(Icons.ios_share, size: 16),
                        label: Text(l10n.share),
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

// Uses the app's current locale (kept in sync with `Intl.defaultLocale` by
// AppLocaleController) so month names follow the selected language.
String _formatDate(DateTime d) => DateFormat.MMMd().format(d);

class _ExpirationSection extends StatelessWidget {
  const _ExpirationSection({
    required this.document,
    required this.onSetDate,
    required this.onChangeReminder,
    required this.onClear,
  });

  final Document document;
  final VoidCallback onSetDate;
  final VoidCallback onChangeReminder;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: SiftColors.sidebar,
        border: Border.all(color: SiftColors.border),
        borderRadius: BorderRadius.circular(11),
      ),
      child: document.hasExpiration
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.event_busy, size: 18, color: SiftColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.expiresOn(_formatDate(document.expiresAt!)),
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 3),
                      GestureDetector(
                        onTap: onChangeReminder,
                        child: Text(
                          l10n.remindMeDaysBeforeChange(document.reminderDaysBefore ?? 30),
                          style: TextStyle(fontSize: 11.5, color: SiftColors.accentDark),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onSetDate,
                  child: Text(l10n.edit),
                ),
                TextButton(
                  onPressed: onClear,
                  child: Text(l10n.clear, style: TextStyle(color: SiftColors.textMuted)),
                ),
              ],
            )
          : Row(
              children: [
                Icon(Icons.event_busy, size: 18, color: SiftColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.notTrackingExpiration,
                    style: TextStyle(fontSize: 13, color: SiftColors.textSecondary),
                  ),
                ),
                TextButton(onPressed: onSetDate, child: Text(l10n.setDate)),
              ],
            ),
    );
  }
}

class _ReminderLeadSheet extends StatelessWidget {
  const _ReminderLeadSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFBFCFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.remindBeforeExpiresTitle,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            for (final days in _reminderLeadOptions)
              ListTile(
                title: Text(l10n.daysBeforeOption(days), style: const TextStyle(fontSize: 13.5)),
                onTap: () => Navigator.of(context).pop(days),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
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
              AppLocalizations.of(context)!.readingAndExtracting(type.label),
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
          Text(AppLocalizations.of(context)!.keyPointsLabel, style: monoStyle(fontSize: 10, fontWeight: FontWeight.w700)),
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
    final l10n = AppLocalizations.of(context)!;
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
            disabled ? l10n.aiDisabledLong : l10n.aiNoSummaryYet,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: SiftColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 13),
          FilledButton.icon(
            onPressed: onSummarize,
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: Text(l10n.summarizeWithAi),
            style: FilledButton.styleFrom(backgroundColor: SiftColors.accent),
          ),
        ],
      ),
    );
  }
}
