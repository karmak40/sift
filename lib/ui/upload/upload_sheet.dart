import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category.dart';
import '../../data/models/document.dart';
import '../../providers/core_providers.dart';
import '../../providers/data_providers.dart';
import '../../providers/library_controller.dart';
import '../theme.dart';
import '../widgets/ai_toggle_row.dart';

Future<void> showUploadSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _UploadSheet(),
  );
}

class _UploadSheet extends ConsumerStatefulWidget {
  const _UploadSheet();

  @override
  ConsumerState<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends ConsumerState<_UploadSheet> {
  final _nameController = TextEditingController();
  DocType _type = DocType.pdf;
  String? _categoryId;
  bool _aiOn = true;
  PlatformFile? _picked;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _aiOn = ref.read(libraryControllerProvider).aiDefaultOn;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    setState(() {
      _picked = file;
      _type = DocType.fromExtension(file.extension);
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = file.name;
      }
    });
  }

  Future<void> _submit(List<Category> categories) async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _categoryId == null) return;
    setState(() => _submitting = true);

    final bytes = _picked?.bytes;
    var storageKey = '';
    var sizeBytes = _picked?.size ?? 0;
    if (bytes != null) {
      storageKey = await ref.read(fileStorageServiceProvider).store(name, bytes);
    }

    await ref.read(documentRepositoryProvider).create(
      name: name,
      type: _type,
      categoryId: _categoryId!,
      sizeBytes: sizeBytes,
      storageKey: storageKey,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? const <Category>[];
    if (_categoryId == null && categories.isNotEmpty) {
      _categoryId = categories.first.id;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFBFCFD),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: SiftColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const Text(
                  'Upload document',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    height: 104,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SiftColors.sidebar,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: SiftColors.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_rounded, color: SiftColors.accent),
                        const SizedBox(height: 6),
                        Text(
                          _picked == null
                              ? 'Tap to choose a file'
                              : _picked!.name,
                          style: TextStyle(fontSize: 12.5, color: SiftColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'File name',
                    hintText: 'e.g. Utility Bill June.pdf',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<DocType>(
                        initialValue: _type,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
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
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
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
                  title: 'Summarize with AI',
                  subtitle: 'Optional — extract key points',
                  value: _aiOn,
                  onChanged: aiFeaturesEnabled
                      ? (v) => setState(() => _aiOn = v)
                      : null,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: (_nameController.text.trim().isEmpty || _submitting)
                        ? null
                        : () => _submit(categories),
                    style: FilledButton.styleFrom(backgroundColor: SiftColors.accent),
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Add document'),
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
