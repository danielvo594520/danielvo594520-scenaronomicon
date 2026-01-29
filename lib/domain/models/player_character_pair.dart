/// プレイヤーとキャラクターのペア（プレイ記録用）
class PlayerCharacterPair {
  const PlayerCharacterPair({
    required this.playerId,
    this.characterId,
  });

  final int playerId;
  final int? characterId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerCharacterPair &&
        other.playerId == playerId &&
        other.characterId == characterId;
  }

  @override
  int get hashCode => Object.hash(playerId, characterId);

  PlayerCharacterPair copyWith({
    int? playerId,
    int? Function()? characterId,
  }) {
    return PlayerCharacterPair(
      playerId: playerId ?? this.playerId,
      characterId: characterId != null ? characterId() : this.characterId,
    );
  }
}
