import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/character_with_stats.dart';
import '../../presentation/providers/character_provider.dart';

/// キャラクター選択ドロップダウン
class CharacterDropdown extends ConsumerWidget {
  const CharacterDropdown({
    super.key,
    required this.playerId,
    required this.selectedCharacterId,
    required this.onChanged,
  });

  final int playerId;
  final int? selectedCharacterId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(characterListProvider(playerId));

    return charactersAsync.when(
      loading: () => const SizedBox(
        width: 150,
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => const Text('エラー'),
      data: (characters) {
        if (characters.isEmpty) {
          return const SizedBox.shrink();
        }

        return DropdownButtonFormField<int?>(
          value: selectedCharacterId,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(),
          ),
          isExpanded: true,
          hint: const Text('キャラクター'),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('選択なし', style: TextStyle(fontStyle: FontStyle.italic)),
            ),
            ...characters.map((character) {
              return DropdownMenuItem<int?>(
                value: character.id,
                child: Text(
                  character.name,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}

/// キャラクター情報を取得するためのシンプルなヘルパー
class CharacterInfo {
  const CharacterInfo({
    required this.id,
    required this.name,
    this.imagePath,
  });

  final int id;
  final String name;
  final String? imagePath;

  factory CharacterInfo.fromCharacterWithStats(CharacterWithStats c) {
    return CharacterInfo(
      id: c.id,
      name: c.name,
      imagePath: c.imagePath,
    );
  }
}
