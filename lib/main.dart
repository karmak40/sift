import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'l10n/app_localizations.dart';
import 'providers/app_init_provider.dart';
import 'providers/app_locale_controller.dart';
import 'ui/home/home_shell.dart';
import 'ui/lock/app_lock_gate.dart';
import 'ui/theme.dart';

void main() {
  runApp(const ProviderScope(child: SiftApp()));
}

/// Picks the best supported locale for the device's preferred-language list,
/// falling back to English (first in [supportedAppLocales]) when none of
/// them match — only used when there's no explicit in-app language override
/// (see [AppLocaleController]). Mirrors what `MaterialApp` would do on its
/// own by default, except it also mirrors the result into
/// `Intl.defaultLocale` for non-widget code.
Locale _resolveSystemLocale(List<Locale>? deviceLocales, Iterable<Locale> supported) {
  if (deviceLocales != null) {
    for (final device in deviceLocales) {
      for (final s in supported) {
        if (s.languageCode == device.languageCode) return s;
      }
    }
  }
  return supported.first;
}

class SiftApp extends ConsumerWidget {
  const SiftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeOverride = ref.watch(appLocaleControllerProvider);
    return MaterialApp(
      title: 'Sift',
      debugShowCheckedModeBanner: false,
      theme: buildSiftTheme(),
      locale: localeOverride.valueOrNull,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeListResolutionCallback: (deviceLocales, supported) {
        final resolved = _resolveSystemLocale(deviceLocales, supported);
        Intl.defaultLocale = resolved.languageCode;
        return resolved;
      },
      home: localeOverride.isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : const _AppRoot(),
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
