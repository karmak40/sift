import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_lock_providers.dart';
import '../theme.dart';

/// Full-screen PIN/biometric prompt shown by `AppLockGate` whenever App Lock
/// is on and the app hasn't been unlocked yet this session.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinController = TextEditingController();
  String? _error;
  bool _checking = false;
  bool _autoBiometricAttempted = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final l10n = AppLocalizations.of(context)!;
    final supported = await ref.read(biometricServiceProvider).isSupported();
    if (!supported || !mounted) return;
    final ok = await ref.read(biometricServiceProvider).authenticate(reason: l10n.biometricUnlockReason);
    if (ok && mounted) {
      ref.read(isUnlockedProvider.notifier).state = true;
    }
  }

  Future<void> _submitPin() async {
    final l10n = AppLocalizations.of(context)!;
    if (_pinController.text.isEmpty) return;
    setState(() {
      _checking = true;
      _error = null;
    });
    final ok = await ref.read(appLockServiceProvider).verifyPin(_pinController.text);
    if (!mounted) return;
    if (ok) {
      ref.read(isUnlockedProvider.notifier).state = true;
    } else {
      setState(() {
        _checking = false;
        _error = l10n.incorrectPin;
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Attempt biometric once automatically as soon as the biometric-support
    // check resolves, so a Face ID/Windows Hello prompt appears right away
    // without the user having to tap anything first.
    final biometricSupported = ref.watch(biometricSupportedProvider);
    if (!_autoBiometricAttempted && biometricSupported.hasValue && biometricSupported.value == true) {
      _autoBiometricAttempted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
    }

    return Scaffold(
      backgroundColor: SiftColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: SiftColors.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.lock_outline, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.siftLocked,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.enterPinToContinue,
                  style: TextStyle(color: SiftColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _pinController,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, letterSpacing: 8),
                  maxLength: 8,
                  onSubmitted: (_) => _submitPin(),
                  decoration: InputDecoration(
                    counterText: '',
                    errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: _checking ? null : _submitPin,
                    style: FilledButton.styleFrom(backgroundColor: SiftColors.accent),
                    child: _checking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.unlock),
                  ),
                ),
                if (biometricSupported.valueOrNull == true) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _tryBiometric,
                    icon: const Icon(Icons.fingerprint, size: 18),
                    label: Text(l10n.useBiometricUnlock),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
