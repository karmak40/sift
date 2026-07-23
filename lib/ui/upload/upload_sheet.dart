import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category.dart';
import '../../data/models/document.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../providers/data_providers.dart';
import '../../providers/document_actions.dart';
import '../../providers/library_controller.dart';
import '../../services/scan/document_scanner_service.dart';
import '../theme.dart';
import '../widgets/ai_toggle_row.dart';
import '../widgets/doc_icon_tile.dart';
import '../widgets/permission_primer.dart';

/// Entry point for the "+" button. On mobile (where scanning is available)
/// it first asks files-vs-scan; elsewhere it goes straight to the file
/// picker. Multi-select routes to a batch review sheet; a single file or a
/// scan routes to the detailed single-document sheet.
Future<void> startAddDocument(BuildContext context, WidgetRef ref) async {
  final scanner = ref.read(documentScannerServiceProvider);
  if (scanner.isSupported) {
    final action = await showModalBottomSheet<_AddAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddActionSheet(),
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case _AddAction.files:
        await _pickAndReview(context, ref);
      case _AddAction.scan:
        final l10n = AppLocalizations.of(context)!;
        final primed = await ensurePermissionPrimed(
          context,
          prefsKey: cameraPrimedKey,
          icon: Icons.camera_alt_outlined,
          title: l10n.cameraPrimerTitle,
          message: l10n.cameraPrimerMessage,
        );
        if (!primed || !context.mounted) return;
        await _scanAndReview(context, ref, scanner);
    }
  } else {
    await _pickAndReview(context, ref);
  }
}

enum _AddAction { files, scan }

PreparedFile _toPrepared(PlatformFile f) => PreparedFile(
  name: f.name,
  type: DocType.fromExtension(f.extension),
  bytes: f.bytes,
  sizeBytes: f.size,
);

Future<void> _pickAndReview(BuildContext context, WidgetRef ref) async {
  final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: true);
  if (result == null || result.files.isEmpty || !context.mounted) return;
  final prepared = result.files.map(_toPrepared).toList();
  if (prepared.length == 1) {
    await _showReviewSheet(context, prepared.first);
  } else {
    await _showBatchSheet(context, prepared);
  }
}

Future<void> _scanAndReview(
  BuildContext context,
  WidgetRef ref,
  DocumentScannerService scanner,
) async {
  final l10n = AppLocalizations.of(context)!;
  Uint8List? pdf;
  try {
    pdf = await scanner.scanToPdf();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scanFailed('$e'))),
      );
    }
    return;
  }
  if (pdf == null || !context.mounted) return; // user cancelled
  final now = DateTime.now();
  final name = '${l10n.scanFilePrefix} ${now.year}-${_two(now.month)}-${_two(now.day)}.pdf';
  await _showReviewSheet(
    context,
    PreparedFile(name: name, type: DocType.pdf, bytes: pdf, sizeBytes: pdf.length),
  );
}

String _two(int n) => n.toString().padLeft(2, '0');

Future<void> _showReviewSheet(BuildContext context, PreparedFile file) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReviewSheet(file: file),
  );
}

Future<void> _showBatchSheet(BuildContext context, List<PreparedFile> files) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BatchSheet(files: files),
  );
}

const _sheetDecoration = BoxDecoration(
  color: Color(0xFFFBFCFD),
  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
);

Widget _grabber() => Center(
  child: Container(
    width: 38,
    height: 4,
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: SiftColors.border,
      borderRadius: BorderRadius.circular(3),
    ),
  ),
);

// ---------------------------------------------------------------------------
// Files-vs-scan chooser (mobile only)
// ---------------------------------------------------------------------------

class _AddActionSheet extends StatelessWidget {
  const _AddActionSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: _sheetDecoration,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            _grabber(),
            ListTile(
              leading: Icon(Icons.upload_file, color: SiftColors.accent),
              title: Text(l10n.chooseFiles),
              subtitle: Text(l10n.chooseFilesSubtitle),
              onTap: () => Navigator.of(context).pop(_AddAction.files),
            ),
            ListTile(
              leading: Icon(Icons.document_scanner_outlined, color: SiftColors.accent),
              title: Text(l10n.scanDocument),
              subtitle: Text(l10n.scanDocumentSubtitle),
              onTap: () => Navigator.of(context).pop(_AddAction.scan),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single-document review
// ---------------------------------------------------------------------------

class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({required this.file});
  final PreparedFile file;

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  late final TextEditingController _nameController;
  late DocType _type;
  String? _categoryId;
  late bool _aiOn;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.file.name);
    _type = widget.file.type;
    _aiOn = ref.read(libraryControllerProvider).aiDefaultOn;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _categoryId == null) return;
    setState(() => _submitting = true);
    await addDocumentsWithRef(
      ref,
      [
        PreparedFile(
          name: name,
          type: _type,
          bytes: widget.file.bytes,
          sizeBytes: widget.file.sizeBytes,
        ),
      ],
      _categoryId!,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    if (_categoryId == null && categories.isNotEmpty) {
      _categoryId = categories.first.id;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: _sheetDecoration,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _grabber(),
                Text(l10n.addDocumentTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    DocIconTile(type: _type, width: 40, height: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _sizeLabel(widget.file.sizeBytes),
                        style: monoStyle(fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l10n.fileNameLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<DocType>(
                        initialValue: _type,
                        decoration: InputDecoration(labelText: l10n.typeLabel, border: const OutlineInputBorder()),
                        items: DocType.values
                            .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                            .toList(),
                        onChanged: (t) => setState(() => _type = t ?? _type),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _categoryId,
                        decoration: InputDecoration(labelText: l10n.categoryLabel, border: const OutlineInputBorder()),
                        items: categories
                            .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                            .toList(),
                        onChanged: (id) => setState(() => _categoryId = id),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                AiToggleRow(
                  title: l10n.summarizeWithAi,
                  subtitle: l10n.aiOptionalSubtitle,
                  value: _aiOn,
                  onChanged: aiFeaturesEnabled ? (v) => setState(() => _aiOn = v) : null,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: (_nameController.text.trim().isEmpty || _submitting) ? null : _submit,
                    style: FilledButton.styleFrom(backgroundColor: SiftColors.accent),
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.addDocumentTitle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Batch (multi-file) review
// ---------------------------------------------------------------------------

class _BatchSheet extends ConsumerStatefulWidget {
  const _BatchSheet({required this.files});
  final List<PreparedFile> files;

  @override
  ConsumerState<_BatchSheet> createState() => _BatchSheetState();
}

class _BatchSheetState extends ConsumerState<_BatchSheet> {
  String? _categoryId;
  late bool _aiOn;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _aiOn = ref.read(libraryControllerProvider).aiDefaultOn;
  }

  Future<void> _submit() async {
    if (_categoryId == null) return;
    setState(() => _submitting = true);
    await addDocumentsWithRef(ref, widget.files, _categoryId!);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    if (_categoryId == null && categories.isNotEmpty) {
      _categoryId = categories.first.id;
    }
    final count = widget.files.length;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: _sheetDecoration,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _grabber(),
                Text(l10n.addDocumentsCount(count), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  l10n.batchSameCategoryNote,
                  style: TextStyle(fontSize: 12.5, color: SiftColors.textSecondary),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: Container(
                    decoration: BoxDecoration(
                      color: SiftColors.sidebar,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: SiftColors.border),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: count,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final f = widget.files[i];
                        return ListTile(
                          dense: true,
                          leading: DocIconTile(type: f.type, width: 28, height: 34),
                          title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                          trailing: Text(_sizeLabel(f.sizeBytes), style: monoStyle(fontSize: 10.5)),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: InputDecoration(labelText: l10n.categoryLabel, border: const OutlineInputBorder()),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (id) => setState(() => _categoryId = id),
                ),
                const SizedBox(height: 15),
                AiToggleRow(
                  title: l10n.summarizeWithAi,
                  subtitle: l10n.aiOptionalSubtitle,
                  value: _aiOn,
                  onChanged: aiFeaturesEnabled ? (v) => setState(() => _aiOn = v) : null,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(backgroundColor: SiftColors.accent),
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.addDocumentsCount(count)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _sizeLabel(int sizeBytes) {
  if (sizeBytes <= 0) return '—';
  const kb = 1024;
  const mb = kb * 1024;
  if (sizeBytes >= mb) return '${(sizeBytes / mb).toStringAsFixed(1)} MB';
  return '${(sizeBytes / kb).toStringAsFixed(0)} KB';
}
