import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/color_utils.dart';
import '../../../data/database/database.dart';
import '../../providers/tag_provider.dart';
import '../../widgets/delete_confirm_dialog.dart';
import '../../widgets/empty_state_widget.dart';

/// プリセットカラー
const _presetColors = [
  '#8B0000', // ダークレッド
  '#FF6347', // トマト
  '#FF8C00', // ダークオレンジ
  '#DAA520', // ゴールデンロッド
  '#2E8B57', // シーグリーン
  '#4169E1', // ロイヤルブルー
  '#9932CC', // ダークオーキッド
  '#2F4F4F', // ダークスレートグレー
  '#8B4513', // サドルブラウン
  '#DC143C', // クリムゾン
  '#008080', // ティール
  '#191970', // ミッドナイトブルー
];

class TagManagementScreen extends ConsumerWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('タグ管理')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tag_management_fab',
        onPressed: () => _showTagDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('エラー: $error')),
        data: (tags) {
          if (tags.isEmpty) {
            return const EmptyStateWidget(
              message: 'タグがありません',
              icon: Icons.label_outlined,
            );
          }
          return ListView.separated(
            itemCount: tags.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tag = tags[index];
              final color = ColorUtils.hexToColor(tag.color);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  radius: 16,
                ),
                title: Text(tag.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () =>
                          _showTagDialog(context, ref, tag: tag),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteTag(context, ref, tag),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showTagDialog(
    BuildContext context,
    WidgetRef ref, {
    Tag? tag,
  }) async {
    final isEdit = tag != null;
    final nameController = TextEditingController(text: tag?.name ?? '');
    final formKey = GlobalKey<FormState>();
    String selectedColor = tag?.color ?? _presetColors[0];

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'タグを編集' : 'タグを追加'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'タグ名',
                    hintText: '例: ホラー',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'タグ名を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('カラー'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _presetColors.map((colorHex) {
                    final isSelected = colorHex == selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = colorHex),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: ColorUtils.hexToColor(colorHex),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final name = nameController.text.trim();

                final exists = await ref
                    .read(tagListProvider.notifier)
                    .isNameExists(name, excludeId: tag?.id);
                if (exists) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('同名のタグが既に存在します')),
                    );
                  }
                  return;
                }

                if (isEdit) {
                  await ref
                      .read(tagListProvider.notifier)
                      .updateTag(tag.id, name, selectedColor);
                } else {
                  await ref
                      .read(tagListProvider.notifier)
                      .add(name, selectedColor);
                }

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(isEdit ? '更新' : '追加'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTag(
    BuildContext context,
    WidgetRef ref,
    Tag tag,
  ) async {
    final confirmed = await DeleteConfirmDialog.show(context, tag.name);
    if (confirmed) {
      await ref.read(tagListProvider.notifier).deleteTag(tag.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${tag.name}」を削除しました')),
        );
      }
    }
  }
}
