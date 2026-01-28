import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/image_picker_service.dart';

/// シナリオフォームで画像を選択するウィジェット
class ImageSelector extends StatelessWidget {
  const ImageSelector({
    super.key,
    this.currentImagePath,
    required this.onImageSelected,
    required this.onImageRemoved,
  });

  final String? currentImagePath;
  final ValueChanged<File> onImageSelected;
  final VoidCallback onImageRemoved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'サムネイル',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 8),
        if (currentImagePath != null)
          _buildImagePreview(context)
        else
          _buildImagePlaceholder(context),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(currentImagePath!),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            semanticLabel: 'サムネイル画像プレビュー',
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder(context);
            },
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                HapticFeedback.lightImpact();
                onImageRemoved();
              },
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showImageSourceDialog(context),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child:
                    Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showImageSourceDialog(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              '画像を追加',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    final pickerService = ImagePickerService();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリーから選択'),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickerService.pickFromGallery();
                if (file != null) {
                  onImageSelected(file);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('カメラで撮影'),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickerService.takePhoto();
                if (file != null) {
                  onImageSelected(file);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
