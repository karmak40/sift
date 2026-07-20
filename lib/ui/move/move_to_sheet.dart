import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category.dart';
import '../../providers/core_providers.dart';
import '../theme.dart';
import '../widgets/category_dot.dart';

Future<void> showMoveToSheet(
  BuildContext context, {
  required List<int> documentIds,
  required List<Category> categories,
  required VoidCallback onMoved,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _MoveToSheet(
      documentIds: documentIds,
      categories: categories,
      onMoved: onMoved,
    ),
  );
}

class _MoveToSheet extends ConsumerWidget {
  const _MoveToSheet({
    required this.documentIds,
    required this.categories,
    required this.onMoved,
  });

  final List<int> documentIds;
  final List<Category> categories;
  final VoidCallback onMoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Move ${documentIds.length} to…',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: categories.map((c) {
                  return ListTile(
                    leading: CategoryDot(hue: c.hue, size: 8),
                    title: Text(c.name, style: const TextStyle(fontSize: 13.5)),
                    onTap: () async {
                      await ref
                          .read(documentRepositoryProvider)
                          .moveToCategory(documentIds, c.id);
                      onMoved();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
