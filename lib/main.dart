import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_init_provider.dart';
import 'ui/home/home_shell.dart';
import 'ui/lock/app_lock_gate.dart';
import 'ui/theme.dart';

void main() {
  runApp(const ProviderScope(child: SiftApp()));
}

class SiftApp extends StatelessWidget {
  const SiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sift',
      debugShowCheckedModeBanner: false,
      theme: buildSiftTheme(),
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends ConsumerWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(appInitProvider);
    return init.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Startup failed: $e'))),
      data: (_) => const AppLockGate(child: HomeShell()),
    );
  }
}
