import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category.dart';
import '../../data/models/document.dart';
import '../../providers/data_providers.dart';
import '../../providers/document_actions.dart';
import '../../providers/library_controller.dart';
import '../document_detail/document_detail_sheet.dart';
import '../move/move_to_sheet.dart';
import '../theme.dart';
import '../widgets/ai_badge.dart';
import '../widgets/category_dot.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/doc_icon_tile.dart';

/// Shared library grid/list. [aiOnly] renders the "AI" tab, which filters to
/// documents that already have a summary.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key, this.aiOnly = false});

  final bool aiOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsProvider);
    final catsAsync = ref.watch(categoriesProvider);
    final uiState = ref.watch(libraryControllerProvider);
    final controller = ref.read(libraryControllerProvider.notifier);

    return docsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Failed to load: $e')),
      data: (docs) {
        final categories = catsAsync.valueOrNull ?? const <Category>[];
        var filtered = controller.apply(docs);
        if (aiOnly) filtered = filtered.where((d) => d.hasAi).toList();
        final catById = {for (final c in categories) c.id: c};

        return Column(
          children: [
            if (!aiOnly) _CategoryChips(categories: categories, uiState: uiState, controller: controller),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            aiOnly
                                ? 'Summarized'
                                : (uiState.activeCategoryId == null
                                    ? 'All documents'
                                    : catById[uiState.activeCategoryId]?.name ?? ''),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${filtered.length} ${filtered.length == 1 ? 'file' : 'files'}',
                          style: monoStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (!aiOnly) ...[
                    const SizedBox(width: 6),
                    PopupMenuButton<SortOrder>(
                      tooltip: 'Sort',
                      initialValue: uiState.sortOrder,
                      onSelected: controller.setSortOrder,
                      itemBuilder: (context) => SortOrder.values
                          .map((o) => PopupMenuItem(value: o, child: Text(o.label)))
                          .toList(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sort, size: 16, color: SiftColors.textSecondary),
                          const SizedBox(width: 2),
                          Icon(Icons.arrow_drop_down, size: 16, color: SiftColors.textSecondary),
                        ],
                      ),
                    ),
                    _ViewToggleButton(
                      icon: Icons.grid_view_rounded,
                      selected: uiState.viewMode == LibraryViewMode.grid,
                      onTap: () => controller.setViewMode(LibraryViewMode.grid),
                    ),
                    _ViewToggleButton(
                      icon: Icons.view_list_rounded,
                      selected: uiState.viewMode == LibraryViewMode.list,
                      onTap: () => controller.setViewMode(LibraryViewMode.list),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(
                      onClear: controller.clearFilters,
                      noDocumentsAtAll: docs.isEmpty,
                      aiOnly: aiOnly,
                    )
                  : (aiOnly || uiState.viewMode == LibraryViewMode.list)
                      ? _DocList(
                          docs: filtered,
                          catById: catById,
                          uiState: uiState,
                          controller: controller,
                          categories: categories,
                        )
                      : _DocGrid(docs: filtered, catById: catById),
            ),
          ],
        );
      },
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({required this.icon, required this.selected, required this.onTap});
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: selected ? SiftColors.accent : SiftColors.textMuted),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.categories, required this.uiState, required this.controller});
  final List<Category> categories;
  final LibraryUiState uiState;
  final LibraryController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _Chip(
            label: 'All',
            selected: uiState.activeCategoryId == null,
            onTap: controller.selectAllDocuments,
          ),
          for (final c in categories)
            Padding(
              padding: const EdgeInsets.only(left: 7),
              child: _Chip(
                label: c.name,
                dotHue: c.hue,
                selected: uiState.activeCategoryId == c.id,
                onTap: () => controller.selectCategory(c.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap, this.dotHue});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double? dotHue;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? SiftColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? SiftColors.accent : SiftColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotHue != null) ...[
              CategoryDot(hue: dotHue!, size: 6),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : SiftColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onClear,
    required this.noDocumentsAtAll,
    required this.aiOnly,
  });

  final VoidCallback onClear;
  final bool noDocumentsAtAll;
  final bool aiOnly;

  @override
  Widget build(BuildContext context) {
    if (noDocumentsAtAll) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            aiOnly
                ? 'No summarized documents yet.'
                : 'No documents yet. Tap + to upload your first document.',
            textAlign: TextAlign.center,
            style: TextStyle(color: SiftColors.textMuted, fontSize: 13),
          ),
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('No documents match.', style: TextStyle(color: SiftColors.textMuted, fontSize: 13)),
          if (!aiOnly) TextButton(onPressed: onClear, child: const Text('Clear filters')),
        ],
      ),
    );
  }
}

class _DocGrid extends StatelessWidget {
  const _DocGrid({required this.docs, required this.catById});
  final List<Document> docs;
  final Map<String, Category> catById;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.98,
      ),
      itemCount: docs.length,
      itemBuilder: (context, i) {
        final doc = docs[i];
        final cat = catById[doc.categoryId];
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => showDocumentDetailSheet(context, document: doc, category: cat),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: SiftColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DocIconTile(type: doc.type, width: 34, height: 40),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.25),
                          ),
                          const SizedBox(height: 2),
                          Text('${doc.sizeLabel} · ${_shortDate(doc.addedAt)}', style: monoStyle(fontSize: 10.5)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (cat != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: hueColorAlpha(cat.hue, 0.13),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CategoryDot(hue: cat.hue, size: 5),
                            const SizedBox(width: 4),
                            Text(cat.name, style: TextStyle(fontSize: 10.5, color: hueColor(cat.hue, lightness: 0.4))),
                          ],
                        ),
                      ),
                    if (doc.hasAi) const AiBadge(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DocList extends ConsumerWidget {
  const _DocList({
    required this.docs,
    required this.catById,
    required this.uiState,
    required this.controller,
    required this.categories,
  });

  final List<Document> docs;
  final Map<String, Category> catById;
  final LibraryUiState uiState;
  final LibraryController controller;
  final List<Category> categories;

  Future<void> _deleteSelected(BuildContext context, WidgetRef ref) async {
    final selected = docs.where((d) => uiState.selectedIds.contains(d.id)).toList();
    if (selected.isEmpty) return;
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${selected.length} ${selected.length == 1 ? 'document' : 'documents'}?',
      message: 'This removes the selected files. This can\'t be undone.',
    );
    if (!confirmed) return;
    await deleteDocumentsWithRef(ref, selected);
    controller.clearSelection();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSelection = uiState.selectedIds.isNotEmpty;
    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 4, 16, hasSelection ? 74 : 24),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final cat = catById[doc.categoryId];
            final selected = uiState.selectedIds.contains(doc.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: selected ? SiftColors.accentSoft : Colors.white,
                border: Border.all(color: SiftColors.border),
                borderRadius: BorderRadius.circular(11),
              ),
              child: ListTile(
                onTap: hasSelection
                    ? () => controller.toggleSelection(doc.id)
                    : () => showDocumentDetailSheet(context, document: doc, category: cat),
                onLongPress: () => controller.toggleSelection(doc.id),
                leading: hasSelection
                    ? Checkbox(value: selected, onChanged: (_) => controller.toggleSelection(doc.id))
                    : DocIconTile(type: doc.type, width: 32, height: 38),
                title: Text(doc.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
                subtitle: Row(
                  children: [
                    if (cat != null) ...[
                      CategoryDot(hue: cat.hue, size: 5),
                      const SizedBox(width: 5),
                      Text(cat.name, style: TextStyle(fontSize: 11, color: hueColor(cat.hue, lightness: 0.4))),
                      const SizedBox(width: 8),
                    ],
                    Text(doc.sizeLabel, style: monoStyle(fontSize: 10.5)),
                    const SizedBox(width: 6),
                    Text(_shortDate(doc.addedAt), style: monoStyle(fontSize: 10.5)),
                  ],
                ),
                trailing: doc.hasAi ? const AiBadge(compact: true) : null,
              ),
            );
          },
        ),
        if (hasSelection)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: SiftColors.sidebar,
                border: Border(top: BorderSide(color: SiftColors.border)),
              ),
              child: Row(
                children: [
                  Text('${uiState.selectedIds.length} selected', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 14),
                  TextButton.icon(
                    onPressed: () => showMoveToSheet(
                      context,
                      documentIds: uiState.selectedIds.toList(),
                      categories: categories,
                      onMoved: controller.clearSelection,
                    ),
                    icon: const Icon(Icons.drive_file_move_outline, size: 16),
                    label: const Text('Move to…'),
                  ),
                  TextButton.icon(
                    onPressed: () => _deleteSelected(context, ref),
                    icon: Icon(Icons.delete_outline, size: 16, color: SiftColors.danger),
                    label: Text('Delete', style: TextStyle(color: SiftColors.danger)),
                  ),
                  const Spacer(),
                  TextButton(onPressed: controller.clearSelection, child: const Text('Clear')),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

String _shortDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}';
}
