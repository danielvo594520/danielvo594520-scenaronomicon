import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/play_session_provider.dart';
import '../../providers/scenario_provider.dart';
import '../../widgets/delete_confirm_dialog.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/tag_chip.dart';

class ScenarioDetailScreen extends ConsumerWidget {
  const ScenarioDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenarioAsync = ref.watch(scenarioDetailProvider(id));

    return scenarioAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('エラー: $error')),
      ),
      data: (scenario) => Scaffold(
        appBar: AppBar(
          title: const Text('シナリオ詳細'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  context.push('/scenarios/${scenario.id}/edit'),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirmed = await DeleteConfirmDialog.show(
                    context, scenario.title);
                if (confirmed && context.mounted) {
                  await ref
                      .read(scenarioListProvider.notifier)
                      .deleteScenario(scenario.id);
                  if (context.mounted) context.pop();
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // サムネイルプレースホルダー
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.image, size: 64, color: Colors.grey[400]),
              ),
              const SizedBox(height: 16),

              // タイトル
              Text(
                scenario.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // システム + ステータス
              Row(
                children: [
                  if (scenario.systemName != null) ...[
                    Chip(
                      label: Text(scenario.systemName!),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                  ],
                  StatusChip(status: scenario.status),
                ],
              ),
              const SizedBox(height: 12),

              // 推奨人数
              _DetailRow(
                icon: Icons.people,
                label: '推奨人数',
                value: scenario.playerCountDisplay,
              ),

              // プレイ時間
              if (scenario.playTimeDisplay != null)
                _DetailRow(
                  icon: Icons.timer,
                  label: 'プレイ時間',
                  value: scenario.playTimeDisplay!,
                ),

              // タグ
              if (scenario.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: scenario.tags
                      .map((tag) =>
                          TagChip(name: tag.name, colorHex: tag.color))
                      .toList(),
                ),
              ],

              // 購入URL
              if (scenario.purchaseUrl != null &&
                  scenario.purchaseUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.link),
                  title: const Text('購入URL'),
                  subtitle: Text(
                    scenario.purchaseUrl!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _launchUrl(scenario.purchaseUrl!),
                ),
              ],

              // メモ
              if (scenario.memo != null &&
                  scenario.memo!.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'メモ',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(scenario.memo!),
              ],

              // プレイ記録セクション
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'プレイ記録',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // プレイ回数
              ref.watch(scenarioPlayCountProvider(scenario.id)).when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('読み込みエラー'),
                    data: (count) => Text(
                      'プレイ回数: $count回',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),

              const SizedBox(height: 12),

              // プレイ履歴
              ref
                  .watch(playSessionsByScenarioProvider(scenario.id))
                  .when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (_, __) =>
                        const Text('履歴の読み込みに失敗しました'),
                    data: (sessions) {
                      if (sessions.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'まだプレイ記録がありません',
                              style:
                                  TextStyle(color: Colors.grey[400]),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => context.push(
                                '/sessions/new?scenarioId=${scenario.id}',
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('プレイ記録を追加'),
                            ),
                          ],
                        );
                      }

                      final dateFormatter = DateFormat('yyyy/MM/dd');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...sessions.map((session) {
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.event),
                                title: Text(dateFormatter
                                    .format(session.playedAt)),
                                subtitle:
                                    session.playerNames.isNotEmpty
                                        ? Text(session.playerNames)
                                        : null,
                                trailing:
                                    const Icon(Icons.chevron_right),
                                onTap: () => context.push(
                                    '/sessions/${session.id}/edit'),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => context.push(
                              '/sessions/new?scenarioId=${scenario.id}',
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('プレイ記録を追加'),
                          ),
                        ],
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Text(value),
        ],
      ),
    );
  }
}
