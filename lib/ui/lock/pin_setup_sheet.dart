import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_lock_providers.dart';
import '../theme.dart';

const _minPinLength = 4;

/// Shows the "set a PIN" bottom sheet (used both for first-time enable and
/// for Settings > Change PIN — it always ends by overwriting whatever PIN
/// existed before). Returns true only if a PIN was actually saved.
Future<bool> showPinSetupSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PinSetupSheet(),
  );
  return result ?? false;
}

class _PinSetupSheet extends ConsumerStatefulWidget {
  const _PinSetupSheet();

  @override
  ConsumerState<_PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends ConsumerState<_PinSetupSheet> {
  final _firstController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _confirming = false;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _firstController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _continueToConfirm() {
    if (_firstController.text.length < _minPinLength) {
      setState(() => _error = AppLocalizations.of(context)!.pinMinLength(_minPinLength));
      return;
    }
    setState(() {
      _confirming = true;
      _error = null;
    });
  }

  Future<void> _confirmAndSave() async {
    if (_confirmController.text != _firstController.text) {
      setState(() {
        _error = AppLocalizations.of(context)!.pinsDontMatch;
        _confirmController.clear();
      });
      return;
    }
    setState(() => _saving = true);
    await ref.read(appLockServiceProvider).setPin(_firstController.text);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFBFCFD),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: SiftColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Text(
                  _confirming ? l10n.confirmYourPin : l10n.setAPin,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  _confirming ? l10n.enterItOneMoreTime : l10n.youllUseThisToUnlock,
                  style: TextStyle(fontSize: 12.5, color: SiftColors.textSecondary),
                ),
                const SizedBox(height: 20),
                TextField(
                  key: ValueKey(_confirming),
                  controller: _confirming ? _confirmController : _firstController,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, letterSpacing: 8),
                  maxLength: 8,
                  decoration: InputDecoration(
                    counterText: '',
                    errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _confirming ? _confirmAndSave() : _continueToConfirm(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: _saving ? null : (_confirming ? _confirmAndSave : _continueToConfirm),
                    style: FilledButton.styleFrom(backgroundColor: SiftColors.accent),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_confirming ? l10n.savePin : l10n.continueButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
