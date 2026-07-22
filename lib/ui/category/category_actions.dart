import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category.dart';
import '../../data/models/document.dart';
import '../../providers/core_providers.dart';
import '../widgets/confirm_dialog.dart';

/// Confirms and deletes a category. Documents that were in it are **not**
/// deleted or reassigned — they just become uncategorized (their
/// `categoryId` no longer matches any category), same as if their category
/// had never existed. The confirmation message says so up front. Returns
/// whether the category was actually deleted (false if the user cancelled).
Future<bool> deleteCategoryWithConfirm(
  BuildContext context,
  WidgetRef ref, {
  required Category category,
  required List<Document> allDocuments,
}) async {
  final docCount = allDocuments.where((d) => d.categoryId == category.id).length;
  final confirmed = await showConfirmDialog(
    context,
    title: 'Delete "${category.name}"?',
    message: docCount == 0
        ? "This category has no documents. This can't be undone."
        : '$docCount ${docCount == 1 ? 'document' : 'documents'} in this category will '
              "become uncategorized rather than being deleted. This can't be undone.",
  );
  if (!confirmed) return false;
  await ref.read(categoryRepositoryProvider).delete(category.id);
  return true;
}
