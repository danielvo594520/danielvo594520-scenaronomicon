import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/play_session_provider.dart';
import '../../widgets/delete_confirm_dialog.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/play_session_card.dart';

/// プレイ記録一覧画面
class PlaySessionListScreen extends ConsumerWidget {
  const PlaySessionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(playSessionListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('プレイ記録')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/sessions/new'),
        child: const Icon(Icons.add),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('エラー: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(playSessionListProvider),
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const EmptyStateWidget(
              message: 'プレイ記録がありません。\n＋ボタンから追加しましょう！',
              icon: Icons.event_note_outlined,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return PlaySessionCard(
                session: session,
                onTap: () => _showSessionActions(
                    context, ref, session.id),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showSessionActions(
    BuildContext context,
    WidgetRef ref,
    int sessionId,
  ) async {
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('編集'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/sessions/$sessionId/edit');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('削除',
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final confirmed = await DeleteConfirmDialog.show(
                    context,
                    'このプレイ記録',
                  );
                  if (confirmed && context.mounted) {
                    await ref
                        .read(playSessionListProvider.notifier)
                        .deleteSession(sessionId);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
