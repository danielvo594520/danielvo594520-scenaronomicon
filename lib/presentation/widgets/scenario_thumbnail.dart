import 'dart:io';

import 'package:flutter/material.dart';

/// シナリオのサムネイル画像を表示するウィジェット
class ScenarioThumbnail extends StatelessWidget {
  const ScenarioThumbnail({
    super.key,
    this.imagePath,
    this.width = 120,
    this.height = 80,
    this.borderRadius = 8,
  });

  final String? imagePath;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return _buildPlaceholder(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.file(
        File(imagePath!),
        width: width,
        height: height,
        fit: BoxFit.cover,
        semanticLabel: 'シナリオのサムネイル画像',
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context);
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: frame != null
                ? child
                : Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.auto_stories,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: height * 0.4,
      ),
    );
  }
}
