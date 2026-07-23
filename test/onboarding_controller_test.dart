import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sift/providers/onboarding_controller.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('defaults to false (not yet seen) for a fresh install', () async {
    final seen = await container.read(onboardingControllerProvider.future);
    expect(seen, isFalse);
  });

  test('markSeen persists the flag and updates state immediately', () async {
    await container.read(onboardingControllerProvider.future);
    await container.read(onboardingControllerProvider.notifier).markSeen();

    expect(container.read(onboardingControllerProvider).valueOrNull, isTrue);

    final freshContainer = ProviderContainer();
    addTearDown(freshContainer.dispose);
    expect(await freshContainer.read(onboardingControllerProvider.future), isTrue);
  });

  test('reads a previously persisted seen flag on a fresh container', () async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
    final freshContainer = ProviderContainer();
    addTearDown(freshContainer.dispose);
    expect(await freshContainer.read(onboardingControllerProvider.future), isTrue);
  });
}
