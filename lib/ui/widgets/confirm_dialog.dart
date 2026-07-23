import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';

/// Shows a Cancel/destructive-action confirmation dialog. Returns true only
/// if the user tapped the destructive action. [confirmLabel]/[cancelLabel]
/// default to localized "Delete"/"Cancel" when omitted.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final confirm = confirmLabel ?? l10n.delete;
  final cancel = cancelLabel ?? l10n.cancel;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            confirm,
            style: TextStyle(color: SiftColors.danger, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
