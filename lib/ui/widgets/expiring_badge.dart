import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';

/// Shown on a document card/row once it's inside its reminder window (or
/// past its expiration date) — see `Document.isExpiringSoon`.
class ExpiringBadge extends StatelessWidget {
  const ExpiringBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: SiftColors.warningSoft,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.event_busy, size: 12, color: SiftColors.warning),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: SiftColors.warningSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy, size: 10, color: SiftColors.warning),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context)!.expiringBadge,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: SiftColors.warning),
          ),
        ],
      ),
    );
  }
}
