import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _onboardingSeenKey = 'has_seen_onboarding';

/// Whether the user has completed (or explicitly finished) the first-launch
/// onboarding carousel — see `lib/ui/onboarding/onboarding_screen.dart` and
/// `SplashGate` in `main.dart`, which reads this to decide whether to show
/// onboarding right after the splash screen. Starts `false` for every real
/// install; once `markSeen()` is called it stays `true` for good (there's no
/// UI to re-trigger onboarding — reinstalling the app is the only reset).
class OnboardingController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSeenKey) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
    state = const AsyncData(true);
  }
}

final onboardingControllerProvider = AsyncNotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);
