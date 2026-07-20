import 'package:flutter/material.dart';

import '../theme.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text.toUpperCase(),
        style: monoStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
