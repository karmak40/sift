import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/category.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../theme.dart';
import '../widgets/category_dot.dart';

const _swatchHues = [150.0, 30.0, 280.0, 90.0, 210.0, 340.0, 250.0, 60.0];

Future<void> showNewCategorySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CategorySheet(),
  );
}

/// Same sheet as [showNewCategorySheet], pre-filled with [category]'s current
/// name/hue and writing changes back via `CategoryRepository.update` instead
/// of creating a new row.
Future<void> showEditCategorySheet(BuildContext context, Category category) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategorySheet(editing: category),
  );
}

class _CategorySheet extends ConsumerStatefulWidget {
  const _CategorySheet({this.editing});

  final Category? editing;

  @override
  ConsumerState<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends ConsumerState<_CategorySheet> {
  late final _nameController = TextEditingController(text: widget.editing?.name ?? '');
  late double _hue = widget.editing?.hue ?? _swatchHues.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final editing = widget.editing;
    if (editing != null) {
      await ref.read(categoryRepositoryProvider).update(editing.copyWith(name: name, hue: _hue));
    } else {
      await ref
          .read(categoryRepositoryProvider)
          .create(Category(id: const Uuid().v4(), name: name, hue: _hue));
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.editing != null;
    final previewName = _nameController.text.trim().isEmpty
        ? l10n.categoryNamePlaceholder
        : _nameController.text.trim();
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
                Row(
                  children: [
                    Text(
                      isEditing ? l10n.editCategoryTitle : l10n.newCategoryTitle,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l10n.nameLabel,
                    hintText: l10n.categoryNameHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.colorLabel, style: monoStyle(fontSize: 11.5, color: SiftColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _swatchHues.map((h) {
                    final selected = _hue == h;
                    return InkWell(
                      onTap: () => setState(() => _hue = h),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: hueColor(h),
                          borderRadius: BorderRadius.circular(10),
                          border: selected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                          boxShadow: selected
                              ? [BoxShadow(color: SiftColors.accent, blurRadius: 0, spreadRadius: 2)]
                              : null,
                        ),
                        child: selected
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                  decoration: BoxDecoration(
                    color: SiftColors.sidebar,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      CategoryDot(hue: _hue, size: 8),
                      const SizedBox(width: 9),
                      Text(previewName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text(l10n.previewLabel, style: monoStyle(fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: _nameController.text.trim().isEmpty ? null : _submit,
                    style: FilledButton.styleFrom(backgroundColor: SiftColors.accent),
                    child: Text(isEditing ? l10n.save : l10n.createCategoryButton),
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
