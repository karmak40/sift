import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sift/providers/app_locale_controller.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('defaults to null (follow system) when nothing is persisted', () async {
    final locale = await container.read(appLocaleControllerProvider.future);
    expect(locale, isNull);
  });

  test('setLocale persists an override and updates state immediately', () async {
    await container.read(appLocaleControllerProvider.future); // let it settle first
    await container.read(appLocaleControllerProvider.notifier).setLocale(const Locale('ru'));

    expect(container.read(appLocaleControllerProvider).valueOrNull, const Locale('ru'));
    expect(Intl.defaultLocale, 'ru');

    // A fresh container reading the same (mocked) prefs sees the persisted choice.
    final freshContainer = ProviderContainer();
    addTearDown(freshContainer.dispose);
    expect(await freshContainer.read(appLocaleControllerProvider.future), const Locale('ru'));
  });

  test('setLocale(null) clears a previous override back to "follow system"', () async {
    final notifier = container.read(appLocaleControllerProvider.notifier);
    await container.read(appLocaleControllerProvider.future);
    await notifier.setLocale(const Locale('de'));
    expect(container.read(appLocaleControllerProvider).valueOrNull, const Locale('de'));

    await notifier.setLocale(null);
    expect(container.read(appLocaleControllerProvider).valueOrNull, isNull);

    final freshContainer = ProviderContainer();
    addTearDown(freshContainer.dispose);
    expect(await freshContainer.read(appLocaleControllerProvider.future), isNull);
  });

  test('supportedAppLocales lists English first, for fallback', () {
    expect(supportedAppLocales.first, const Locale('en'));
    expect(supportedAppLocales, containsAll(const [Locale('en'), Locale('ru'), Locale('uk'), Locale('de')]));
  });
}
