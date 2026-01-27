import 'package:flutter/material.dart';

class DeleteConfirmDialog extends StatelessWidget {
  const DeleteConfirmDialog({super.key, required this.itemName});

  final String itemName;

  static Future<bool> show(BuildContext context, String itemName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmDialog(itemName: itemName),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('削除の確認'),
      content: Text('「$itemName」を削除しますか？\nこの操作は取り消せません。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('削除'),
        ),
      ],
    );
  }
}
