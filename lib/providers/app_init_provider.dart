import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/seed_data.dart';
import 'core_providers.dart';

/// Seeds demo data on first run. `main.dart` awaits this before showing the
/// library so the seed rows are already in the DB when the stream providers
/// first fire.
final appInitProvider = FutureProvider<void>((ref) async {
  await seedIfEmpty(
    ref.watch(categoryRepositoryProvider),
    ref.watch(documentRepositoryProvider),
  );
});
