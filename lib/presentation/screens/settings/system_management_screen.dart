import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../providers/system_provider.dart';
import '../../widgets/delete_confirm_dialog.dart';
import '../../widgets/empty_state_widget.dart';

class SystemManagementScreen extends ConsumerWidget {
  const SystemManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemsAsync = ref.watch(systemListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ゲームシステム管理')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'system_management_fab',
        onPressed: () => _showSystemDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: systemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('エラー: $error')),
        data: (systems) {
          if (systems.isEmpty) {
            return const EmptyStateWidget(
              message: 'ゲームシステムがありません',
              icon: Icons.gamepad_outlined,
            );
          }
          return ListView.separated(
            itemCount: systems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final system = systems[index];
              return ListTile(
                title: Text(system.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () =>
                          _showSystemDialog(context, ref, system: system),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteSystem(context, ref, system),
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

  Future<void> _showSystemDialog(
    BuildContext context,
    WidgetRef ref, {
    System? system,
  }) async {
    final isEdit = system != null;
    final controller = TextEditingController(text: system?.name ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? 'システムを編集' : 'システムを追加'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'システム名',
              hintText: '例: 新クトゥルフ神話TRPG',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'システム名を入力してください';
              }
              return null;
            },
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
              final name = controller.text.trim();

              final exists = await ref
                  .read(systemListProvider.notifier)
                  .isNameExists(name, excludeId: system?.id);
              if (exists) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('同名のシステムが既に存在します')),
                  );
                }
                return;
              }

              if (isEdit) {
                await ref
                    .read(systemListProvider.notifier)
                    .updateSystem(system.id, name);
              } else {
                await ref.read(systemListProvider.notifier).add(name);
              }

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(isEdit ? '更新' : '追加'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSystem(
    BuildContext context,
    WidgetRef ref,
    System system,
  ) async {
    final confirmed = await DeleteConfirmDialog.show(context, system.name);
    if (confirmed) {
      await ref.read(systemListProvider.notifier).deleteSystem(system.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${system.name}」を削除しました')),
        );
      }
    }
  }
}
