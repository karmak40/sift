import 'package:flutter/material.dart';

import '../theme.dart';

class AiBadge extends StatelessWidget {
  const AiBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: SiftColors.accentSoft,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.auto_awesome, size: 12, color: SiftColors.accentDark),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: SiftColors.accentSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 10, color: SiftColors.accentDark),
          const SizedBox(width: 4),
          Text(
            'AI',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: SiftColors.accentDark,
            ),
          ),
        ],
      ),
    );
  }
}
