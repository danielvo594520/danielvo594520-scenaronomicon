import 'package:flutter/material.dart';

import '../../core/utils/color_utils.dart';

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.name,
    required this.colorHex,
  });

  final String name;
  final String colorHex;

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.hexToColor(colorHex);
    final luminance = color.computeLuminance();
    final textColor = luminance > 0.5 ? Colors.black : Colors.white;

    return Chip(
      label: Text(
        name,
        style: TextStyle(color: textColor, fontSize: 12),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }
}
