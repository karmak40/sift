import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/category.dart';
import '../data/models/document.dart';
import 'core_providers.dart';

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

final documentsProvider = StreamProvider<List<Document>>((ref) {
  return ref.watch(documentRepositoryProvider).watchAll();
});
