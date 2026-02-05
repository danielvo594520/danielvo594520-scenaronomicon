import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/character_sheet/character_sheet_result.dart';
import '../../providers/character_provider.dart';
import '../../providers/character_sheet_provider.dart';
import '../../widgets/image_selector.dart';

/// キャラクター追加/編集画面
class CharacterFormScreen extends ConsumerStatefulWidget {
  const CharacterFormScreen({
    super.key,
    required this.playerId,
    this.characterId,
  });

  final int playerId;
  final int? characterId;

  @override
  ConsumerState<CharacterFormScreen> createState() =>
      _CharacterFormScreenState();
}

class _CharacterFormScreenState extends ConsumerState<CharacterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  String? _currentImagePath;
  File? _newImageFile;
  bool _deleteImage = false;
  bool _isInitialized = false;
  bool _isSaving = false;

  // ステータス情報
  int? _hp;
  int? _maxHp;
  int? _mp;
  int? _maxMp;
  int? _san;
  int? _maxSan;
  String? _sourceService;

  // 能力値・技能値
  Map<String, int>? _params;
  Map<String, int>? _skills;

  bool get _isEdit => widget.characterId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _initializeFromCharacter() {
    if (_isInitialized || !_isEdit) return;
    final characterAsync =
        ref.read(characterDetailProvider(widget.characterId!));
    characterAsync.whenData((character) {
      if (_isInitialized) return;
      _nameController.text = character.name;
      _urlController.text = character.url ?? '';
      _currentImagePath = character.imagePath;
      _hp = character.hp;
      _maxHp = character.maxHp;
      _mp = character.mp;
      _maxMp = character.maxMp;
      _san = character.san;
      _maxSan = character.maxSan;
      _sourceService = character.sourceService;
      _params = character.params;
      _skills = character.skills;
      _isInitialized = true;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isEdit) {
      ref.watch(characterDetailProvider(widget.characterId!));
      _initializeFromCharacter();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'キャラクターを編集' : 'キャラクターを追加'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 画像選択
              ImageSelector(
                currentImagePath: _deleteImage
                    ? null
                    : (_newImageFile?.path ?? _currentImagePath),
                onImageSelected: (file) {
                  setState(() {
                    _newImageFile = file;
                    _deleteImage = false;
                  });
                },
                onImageRemoved: () {
                  setState(() {
                    _newImageFile = null;
                    _deleteImage = true;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 名前
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'キャラクター名 *',
                  hintText: '例: 田中太郎',
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'キャラクター名を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // URL入力欄
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'キャラクターシートURL',
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.link),
                  helperText: 'ココフォリア駒から自動入力可能',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  final uri = Uri.tryParse(value.trim());
                  if (uri == null || !uri.hasScheme) {
                    return '有効なURLを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ココフォリア駒から入力ボタン
              OutlinedButton.icon(
                onPressed: _showCcfoliaInputDialog,
                icon: const Icon(Icons.content_paste),
                label: const Text('ココフォリア駒から入力'),
              ),
              const SizedBox(height: 16),

              // 既存のステータス情報がある場合
              if (_hasStats) ...[
                _buildCurrentStatsCard(),
                const SizedBox(height: 16),
              ],

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

  Widget _buildCurrentStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined),
                const SizedBox(width: 8),
                Text(
                  'ステータス情報',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_sourceService != null) ...[
                  const Spacer(),
                  Chip(
                    label: Text(_sourceService!),
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            const Divider(),
            _buildStatsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HP/MP/SAN
        if (_hp != null || _maxHp != null || _mp != null || _maxMp != null || _san != null || _maxSan != null)
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (_hp != null || _maxHp != null)
                _buildStatChip('HP', _hp, _maxHp, Colors.red),
              if (_mp != null || _maxMp != null)
                _buildStatChip('MP', _mp, _maxMp, Colors.blue),
              if (_san != null || _maxSan != null)
                _buildStatChip('SAN', _san, _maxSan, Colors.purple),
            ],
          ),

        // 能力値
        if (_params != null && _params!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '能力値',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _params!.entries.map((e) {
              return _buildParamChip(e.key, e.value);
            }).toList(),
          ),
        ],

        // 技能値
        if (_skills != null && _skills!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '技能値',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _skills!.entries.map((e) {
              return _buildParamChip(e.key, e.value);
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStatChip(String label, int? current, int? max, Color color) {
    // maxがある場合は「current / max」、ない場合は「current」のみ
    final valueText = max != null
        ? '${current ?? '?'} / $max'
        : '${current ?? '?'}';

    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withAlpha(50),
        child: Text(
          label[0],
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
      label: Text(valueText),
    );
  }

  Widget _buildParamChip(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 6),
          Text(
            '$value',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  bool get _hasStats =>
      _hp != null ||
      _maxHp != null ||
      _mp != null ||
      _maxMp != null ||
      _san != null ||
      _maxSan != null ||
      (_params != null && _params!.isNotEmpty) ||
      (_skills != null && _skills!.isNotEmpty);

  /// ココフォリア駒入力ダイアログを表示
  Future<void> _showCcfoliaInputDialog() async {
    final result = await showDialog<CharacterSheetResult>(
      context: context,
      builder: (context) => const _CcfoliaInputDialog(),
    );

    if (result != null && mounted) {
      _applyResult(result);
    }
  }

  void _applyResult(CharacterSheetResult result) {
    setState(() {
      // 名前が取得できていて、現在空の場合のみ適用
      if (result.name != null && _nameController.text.trim().isEmpty) {
        _nameController.text = result.name!;
      }

      // URLが取得できていて、現在空の場合のみ適用
      if (result.externalUrl != null && _urlController.text.trim().isEmpty) {
        _urlController.text = result.externalUrl!;
      }

      // ステータス情報を適用
      _hp = result.hp;
      _maxHp = result.maxHp;
      _mp = result.mp;
      _maxMp = result.maxMp;
      _san = result.san;
      _maxSan = result.maxSan;
      _sourceService = 'ココフォリア';

      // 能力値・技能値を適用
      _params = result.params;
      _skills = result.skills;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('キャラクター情報を適用しました')),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final url = _urlController.text.trim().isEmpty
          ? null
          : _urlController.text.trim();

      if (_isEdit) {
        await ref
            .read(characterListProvider(widget.playerId).notifier)
            .updateCharacter(
              id: widget.characterId!,
              name: name,
              url: url,
              newImageFile: _newImageFile,
              deleteImage: _deleteImage,
              hp: _hp,
              maxHp: _maxHp,
              mp: _mp,
              maxMp: _maxMp,
              san: _san,
              maxSan: _maxSan,
              sourceService: _sourceService,
              params: _params,
              skills: _skills,
            );
        ref.invalidate(characterDetailProvider(widget.characterId!));
      } else {
        await ref
            .read(characterListProvider(widget.playerId).notifier)
            .add(
              name: name,
              url: url,
              imageFile: _newImageFile,
              hp: _hp,
              maxHp: _maxHp,
              mp: _mp,
              maxMp: _maxMp,
              san: _san,
              maxSan: _maxSan,
              sourceService: _sourceService,
              params: _params,
              skills: _skills,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(_isEdit ? 'キャラクターを更新しました' : 'キャラクターを追加しました'),
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

/// ココフォリア駒入力ダイアログ
class _CcfoliaInputDialog extends ConsumerStatefulWidget {
  const _CcfoliaInputDialog();

  @override
  ConsumerState<_CcfoliaInputDialog> createState() =>
      _CcfoliaInputDialogState();
}

class _CcfoliaInputDialogState extends ConsumerState<_CcfoliaInputDialog> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parseState = ref.watch(ccfoliaParseProvider);

    return AlertDialog(
      title: const Text('ココフォリア駒から入力'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                'ココフォリアで「駒を出力」したJSONを貼り付けてください',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: '{"kind":"character","data":{...}}',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  // テキスト変更時にパース実行
                  ref.read(ccfoliaParseProvider.notifier).parse(
                        _textController.text,
                      );
                },
              ),
              const SizedBox(height: 16),

              // パース結果表示
              _buildParseResult(parseState),
            ],
          ),
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(ccfoliaParseProvider.notifier).reset();
            Navigator.of(context).pop();
          },
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: parseState is CcfoliaParseSuccess
              ? () {
                  ref.read(ccfoliaParseProvider.notifier).reset();
                  Navigator.of(context).pop(parseState.result);
                }
              : null,
          child: const Text('適用'),
        ),
      ],
    );
  }

  Widget _buildParseResult(CcfoliaParseState state) {
    if (state is CcfoliaParseIdle) {
      return const SizedBox.shrink();
    }

    if (state is CcfoliaParseError) {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is CcfoliaParseSuccess) {
      final result = state.result;
      return Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '取得したデータ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const Divider(),

              // 基本情報
              if (result.name != null)
                _buildResultRow('名前', result.name!),
              if (result.externalUrl != null)
                _buildResultRow('URL', result.externalUrl!, maxLines: 1),

              // HP/MP/SAN
              if (result.hp != null)
                _buildResultRow('HP', '${result.hp}'),
              if (result.mp != null)
                _buildResultRow('MP', '${result.mp}'),
              if (result.san != null)
                _buildResultRow('SAN', '${result.san}'),

              // 能力値
              if (result.hasParams) ...[
                const SizedBox(height: 8),
                Text(
                  '能力値',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: result.params!.entries.map((e) {
                    return _buildSmallChip('${e.key}: ${e.value}');
                  }).toList(),
                ),
              ],

              // 技能値
              if (result.hasSkills) ...[
                const SizedBox(height: 8),
                Text(
                  '技能値',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: result.skills!.entries.map((e) {
                    return _buildSmallChip('${e.key}: ${e.value}');
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildResultRow(String label, String value, {int? maxLines}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: maxLines,
              overflow: maxLines != null ? TextOverflow.ellipsis : null,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
