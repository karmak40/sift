import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/seed_data.dart';
import 'core_providers.dart';

/// Seeds default categories on first run. `main.dart` awaits this before
/// showing the library so the categories exist by the time the stream
/// providers first fire. No documents are seeded — the library only ever
/// shows what the user has actually uploaded.
final appInitProvider = FutureProvider<void>((ref) async {
  await seedIfEmpty(ref.watch(categoryRepositoryProvider));
});
