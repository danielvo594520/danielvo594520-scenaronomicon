import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/player_character_pair.dart';
import '../../providers/character_provider.dart';
import '../../providers/play_session_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/player_character_select.dart';
import '../../widgets/scenario_search_dropdown.dart';

/// プレイ記録追加/編集画面
class PlaySessionFormScreen extends ConsumerStatefulWidget {
  const PlaySessionFormScreen({
    super.key,
    this.sessionId,
    this.preselectedScenarioId,
  });

  final int? sessionId;
  final int? preselectedScenarioId;

  @override
  ConsumerState<PlaySessionFormScreen> createState() =>
      _PlaySessionFormScreenState();
}

class _PlaySessionFormScreenState
    extends ConsumerState<PlaySessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _memoController = TextEditingController();

  int? _selectedScenarioId;
  DateTime _playedAt = DateTime.now();
  List<PlayerCharacterPair> _selectedPairs = [];
  bool _isInitialized = false;
  bool _isSaving = false;

  bool get _isEdit => widget.sessionId != null;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedScenarioId != null) {
      _selectedScenarioId = widget.preselectedScenarioId;
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void _initializeFromSession() {
    if (_isInitialized || !_isEdit) return;

    // セッション詳細とペア情報の両方を取得
    final sessionAsync =
        ref.read(playSessionDetailProvider(widget.sessionId!));
    final pairsAsync =
        ref.read(playSessionPlayerCharacterPairsProvider(widget.sessionId!));

    sessionAsync.whenData((session) {
      pairsAsync.whenData((pairs) {
        if (_isInitialized) return;
        _selectedScenarioId = session.scenarioId;
        _playedAt = session.playedAt;
        _memoController.text = session.memo ?? '';
        _selectedPairs = pairs;
        _isInitialized = true;
        if (mounted) setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isEdit) {
      ref.watch(playSessionDetailProvider(widget.sessionId!));
      ref.watch(playSessionPlayerCharacterPairsProvider(widget.sessionId!));
      _initializeFromSession();
    }

    final dateFormatter = DateFormat('yyyy年MM月dd日');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'プレイ記録を編集' : 'プレイ記録を追加'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // シナリオ選択
              ScenarioSearchDropdown(
                selectedScenarioId: _selectedScenarioId,
                onChanged: (value) =>
                    setState(() => _selectedScenarioId = value),
              ),
              const SizedBox(height: 16),

              // プレイ日
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'プレイ日 *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(dateFormatter.format(_playedAt)),
                ),
              ),
              const SizedBox(height: 16),

              // プレイヤー・キャラクター選択
              PlayerCharacterSelect(
                selectedPairs: _selectedPairs,
                onChanged: (value) => setState(() => _selectedPairs = value),
              ),
              const SizedBox(height: 16),

              // メモ
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: 'メモ',
                  hintText: 'プレイの感想など',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              // 保存ボタン
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isEdit ? '更新' : '保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _playedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _playedAt = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final memo = _memoController.text.trim().isEmpty
          ? null
          : _memoController.text.trim();

      if (_isEdit) {
        await ref.read(playSessionListProvider.notifier).updateSession(
              id: widget.sessionId!,
              scenarioId: _selectedScenarioId,
              playedAt: _playedAt,
              memo: memo,
              playerCharacterPairs: _selectedPairs,
            );
        ref.invalidate(playSessionDetailProvider(widget.sessionId!));
        ref.invalidate(
            playSessionPlayerCharacterPairsProvider(widget.sessionId!));
      } else {
        await ref.read(playSessionListProvider.notifier).add(
              scenarioId: _selectedScenarioId,
              playedAt: _playedAt,
              memo: memo,
              playerCharacterPairs: _selectedPairs,
            );
      }

      // シナリオのプレイ回数を更新
      if (_selectedScenarioId != null) {
        ref.invalidate(scenarioPlayCountProvider(_selectedScenarioId!));
        ref.invalidate(
            playSessionsByScenarioProvider(_selectedScenarioId!));
      }

      // プレイヤーの参加数を更新
      ref.invalidate(playerListProvider);
      for (final pair in _selectedPairs) {
        ref.invalidate(playerSessionCountProvider(pair.playerId));
        ref.invalidate(playerPlayedScenariosProvider(pair.playerId));
        // キャラクターの統計も更新
        ref.invalidate(characterListProvider(pair.playerId));
        if (pair.characterId != null) {
          ref.invalidate(characterSessionCountProvider(pair.characterId!));
          ref.invalidate(characterPlayedSessionsProvider(pair.characterId!));
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(_isEdit ? 'プレイ記録を更新しました' : 'プレイ記録を追加しました'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
