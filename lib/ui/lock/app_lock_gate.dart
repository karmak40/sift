import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_lock_providers.dart';
import 'lock_screen.dart';

/// Wraps the real app: shows [LockScreen] instead of [child] whenever App
/// Lock is on and the session hasn't been unlocked yet. Also the thing that
/// actually re-locks — without resetting `isUnlockedProvider` when the app
/// is backgrounded, "App Lock" would only ever protect a cold start, which
/// isn't what anyone means by "lock my documents".
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // `inactive` fires on transient focus loss too (e.g. a brief alt-tab on
    // desktop) — only truly backgrounding/minimizing should re-lock.
    if (state != AppLifecycleState.paused && state != AppLifecycleState.hidden) return;
    final enabled = ref.read(appLockEnabledProvider).valueOrNull ?? false;
    if (enabled) {
      ref.read(isUnlockedProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabledAsync = ref.watch(appLockEnabledProvider);
    final unlocked = ref.watch(isUnlockedProvider);

    // Only show a blocking spinner before we've ever resolved a value (cold
    // start) — once we have one, keep using it during a refresh (e.g. right
    // after the Settings toggle calls ref.invalidate) instead of flashing a
    // spinner over the app.
    if (enabledAsync.valueOrNull == null && !enabledAsync.hasError) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Fail open on a read error rather than locking someone out of their
    // own library over a storage glitch — App Lock is a convenience layer
    // on a personal document vault, not a security boundary worth risking
    // permanent lockout for.
    final enabled = enabledAsync.valueOrNull ?? false;

    if (!enabled || unlocked) {
      return widget.child;
    }
    return const LockScreen();
  }
}
