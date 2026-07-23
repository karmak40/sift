import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'app_locale';

/// Languages Sift ships translations for. English is deliberately first —
/// it's the fallback whenever the device's own locale isn't one of these
/// (see `_resolveSystemLocale` in `main.dart`).
const supportedAppLocales = [Locale('en'), Locale('ru'), Locale('uk'), Locale('de')];

/// The user's language override, persisted via shared_preferences. `null`
/// means "follow the OS locale" — `main.dart`'s `localeListResolutionCallback`
/// does the actual system-locale-with-English-fallback resolution in that
/// case. Either way, whichever locale ends up active also gets mirrored into
/// `Intl.defaultLocale` so non-widget code (date formatting in
/// `library_screen.dart`/`document_detail_sheet.dart`, seeded category names,
/// reminder notification text) sees the same language without needing a
/// `BuildContext`.
class AppLocaleController extends AsyncNotifier<Locale?> {
  @override
  Future<Locale?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null) return null;
    Intl.defaultLocale = code;
    return Locale(code);
  }

  /// Pass null to go back to following the OS locale.
  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
      Intl.defaultLocale = locale.languageCode;
    }
    state = AsyncData(locale);
  }
}

final appLocaleControllerProvider = AsyncNotifierProvider<AppLocaleController, Locale?>(
  AppLocaleController.new,
);
