import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';

/// Shared shared_preferences keys for each permission primer — kept as
/// named constants (rather than inline string literals at each call site)
/// since a typo would silently create a second, never-primed flag instead
/// of failing loudly.
const cameraPrimedKey = 'primed_camera';
const notificationsPrimedKey = 'primed_notifications';

/// `settings_screen.dart` sets this (via [ensurePermissionPrimed], offered
/// right after PIN setup succeeds) and `lock_screen.dart` reads it (via
/// [isPermissionPrimed]) to decide whether it's safe to auto-attempt
/// biometric unlock without asking anything first.
const biometricPrimedKey = 'primed_biometric';

/// Shows a plain-language explanation *before* an action that would
/// otherwise trigger a cold OS permission prompt (camera, biometric,
/// notifications) — so the system dialog never appears out of nowhere.
/// Returns true if the caller should proceed with the permission-triggering
/// action, false if the user declined.
///
/// Persisted per [prefsKey] via shared_preferences, but **only when the
/// user continues** — a decline doesn't mark it seen, so trying the same
/// feature again later re-offers the explanation instead of silently
/// skipping straight to (or blocking) the OS prompt forever.
Future<bool> ensurePermissionPrimed(
  BuildContext context, {
  required String prefsKey,
  required IconData icon,
  required String title,
  required String message,
}) async {
  if (await isPermissionPrimed(prefsKey)) return true;
  if (!context.mounted) return false;

  final proceed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _PermissionPrimerSheet(icon: icon, title: title, message: message),
  );
  if (proceed == true) {
    await (await SharedPreferences.getInstance()).setBool(prefsKey, true);
    return true;
  }
  return false;
}

/// Read-only check for whether [prefsKey] has already been primed —
/// lets a caller (e.g. the lock screen's automatic biometric attempt)
/// decide whether it's safe to trigger the real permission-requiring
/// action without showing anything first, versus needing to go through
/// [ensurePermissionPrimed] itself.
Future<bool> isPermissionPrimed(String prefsKey) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(prefsKey) ?? false;
}

class _PermissionPrimerSheet extends StatelessWidget {
  const _PermissionPrimerSheet({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFBFCFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: SiftColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: SiftColors.accentSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: SiftColors.accent, size: 28),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: SiftColors.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(backgroundColor: SiftColors.accent),
                  child: Text(l10n.continueButton),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.notNow, style: TextStyle(color: SiftColors.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
