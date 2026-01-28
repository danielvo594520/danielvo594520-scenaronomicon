import 'package:flutter/material.dart';

import '../../domain/models/scenario_with_tags.dart';
import 'scenario_thumbnail.dart';
import 'status_chip.dart';
import 'tag_chip.dart';

class ScenarioCard extends StatelessWidget {
  const ScenarioCard({
    super.key,
    required this.scenario,
    required this.onTap,
  });

  final ScenarioWithTags scenario;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // サムネイル
            ScenarioThumbnail(
              imagePath: scenario.thumbnailPath,
              width: 100,
              height: 120,
              borderRadius: 0,
            ),
            // コンテンツ
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイトル
                    Text(
                      scenario.title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // システム名 + ステータス
                    Row(
                      children: [
                        if (scenario.systemName != null) ...[
                          Flexible(
                            child: Text(
                              scenario.systemName!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        StatusChip(status: scenario.status),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 人数
                    Text(
                      '推奨人数: ${scenario.playerCountDisplay}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    // タグ
                    if (scenario.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: scenario.tags
                            .map((tag) => TagChip(
                                name: tag.name, colorHex: tag.color))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
