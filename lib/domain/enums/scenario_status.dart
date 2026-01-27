import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum ScenarioStatus {
  unread('未読', AppColors.statusUnread),
  reading('読み中', AppColors.statusReading),
  preparing('準備中', AppColors.statusPreparing),
  ready('準備完了', AppColors.statusReady),
  played('回した', AppColors.statusPlayed),
  archived('アーカイブ', AppColors.statusArchived);

  const ScenarioStatus(this.displayName, this.color);

  final String displayName;
  final Color color;
}
