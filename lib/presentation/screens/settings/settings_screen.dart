import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.gamepad_outlined),
            title: const Text('ゲームシステム管理'),
            subtitle: const Text('ゲームシステムの追加・編集・削除'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/systems'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.label_outlined),
            title: const Text('タグ管理'),
            subtitle: const Text('タグの追加・編集・削除'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/tags'),
          ),
          const Divider(height: 1),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Version ${AppConstants.appVersion}',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
