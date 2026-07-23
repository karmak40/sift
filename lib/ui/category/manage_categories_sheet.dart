import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category.dart';
import '../../data/models/document.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/data_providers.dart';
import '../theme.dart';
import '../widgets/category_dot.dart';
import 'category_actions.dart';
import 'new_category_sheet.dart';

Future<void> showManageCategoriesSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ManageCategoriesSheet(),
  );
}

class _ManageCategoriesSheet extends ConsumerWidget {
  const _ManageCategoriesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    final docs = ref.watch(documentsProvider).valueOrNull ?? const <Document>[];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
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
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                child: Row(
                  children: [
                    Text(
                      l10n.categoriesTitle,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => showNewCategorySheet(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(l10n.newCategoryButton),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: categories.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noCategoriesYet,
                          style: TextStyle(color: SiftColors.textMuted, fontSize: 13),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: categories.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final cat = categories[i];
                          final count = docs.where((d) => d.categoryId == cat.id).length;
                          return ListTile(
                            leading: CategoryDot(hue: cat.hue, size: 10),
                            title: Text(cat.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.fileCount(count),
                                  style: monoStyle(fontSize: 11.5),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: SiftColors.danger, size: 20),
                                  tooltip: l10n.deleteCategoryTooltip,
                                  onPressed: () => deleteCategoryWithConfirm(
                                    context,
                                    ref,
                                    category: cat,
                                    allDocuments: docs,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
