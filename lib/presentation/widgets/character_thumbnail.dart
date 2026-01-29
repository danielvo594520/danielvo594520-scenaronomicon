import 'dart:io';

import 'package:flutter/material.dart';

/// キャラクターのサムネイル画像を表示するウィジェット
class CharacterThumbnail extends StatelessWidget {
  const CharacterThumbnail({
    super.key,
    this.imagePath,
    this.size = 48,
    this.borderRadius = 24,
  });

  final String? imagePath;
  final double size;
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
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: 'キャラクターの画像',
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
                    width: size,
                    height: size,
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
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.person,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: size * 0.5,
      ),
    );
  }
}
