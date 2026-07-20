import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../theme.dart';

/// A labeled switch row for AI-related settings. When `AppConfig.aiEnabled`
/// is false, [onChanged] should be left null by the caller so the row
/// renders as disabled — this is the single place that visual state lives.
class AiToggleRow extends StatelessWidget {
  const AiToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final disabled = onChanged == null;
    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: SiftColors.accentSoft,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: SiftColors.accentSoftBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SiftColors.accent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    disabled ? '$subtitle · disabled for now' : subtitle,
                    style: TextStyle(fontSize: 11, color: SiftColors.textSecondary),
                  ),
                ],
              ),
            ),
            Switch(
              value: disabled ? false : value,
              onChanged: onChanged,
              activeTrackColor: SiftColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}

/// True while AI features stay off. Kept as a tiny helper so screens don't
/// each re-import AppConfig directly.
bool get aiFeaturesEnabled => AppConfig.aiEnabled;
