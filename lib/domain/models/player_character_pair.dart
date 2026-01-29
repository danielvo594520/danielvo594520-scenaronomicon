/// プレイヤーとキャラクターのペア（プレイ記録用）
class PlayerCharacterPair {
  const PlayerCharacterPair({
    required this.playerId,
    this.characterId,
    this.isKp = false,
  });

  final int playerId;
  final int? characterId;
  final bool isKp;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerCharacterPair &&
        other.playerId == playerId &&
        other.characterId == characterId &&
        other.isKp == isKp;
  }

  @override
  int get hashCode => Object.hash(playerId, characterId, isKp);

  PlayerCharacterPair copyWith({
    int? playerId,
    int? Function()? characterId,
    bool? isKp,
  }) {
    return PlayerCharacterPair(
      playerId: playerId ?? this.playerId,
      characterId: characterId != null ? characterId() : this.characterId,
      isKp: isKp ?? this.isKp,
    );
  }
}
