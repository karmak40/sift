import 'package:flutter/material.dart';

import '../theme.dart';

class CategoryDot extends StatelessWidget {
  const CategoryDot({super.key, required this.hue, this.size = 6});

  final double hue;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hueColor(hue),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
