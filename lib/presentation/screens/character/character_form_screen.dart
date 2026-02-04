import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/character_sheet/character_sheet_result.dart';
import '../../../core/services/character_sheet/character_sheet_service_factory.dart';
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

  bool get _isEdit => widget.characterId != null;
  final _factory = CharacterSheetServiceFactory();

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

    // URL変更時にサービス対応状況を更新
    final url = _urlController.text.trim();
    final canFetch = _factory.canHandle(url);
    final serviceName = _factory.getServiceName(url);

    // キャラクターシート取得状態を監視
    final fetchState = ref.watch(characterSheetFetchProvider);

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

              // URL + 取得ボタン
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'キャラクターシートURL',
                        hintText: 'https://...',
                        prefixIcon: const Icon(Icons.link),
                        helperText: canFetch ? '対応: $serviceName' : null,
                        helperStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      onChanged: (_) => setState(() {}),
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
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildFetchButton(canFetch, fetchState),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 取得結果プレビュー / ステータス表示
              _buildFetchResultOrStatus(fetchState),

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

  Widget _buildFetchButton(bool canFetch, CharacterSheetFetchState fetchState) {
    final isLoading = fetchState is CharacterSheetFetchLoading;

    return FilledButton.tonalIcon(
      onPressed: canFetch && !isLoading ? _fetchCharacterSheet : null,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download),
      label: const Text('取得'),
    );
  }

  Widget _buildFetchResultOrStatus(CharacterSheetFetchState fetchState) {
    // 取得成功時のプレビュー
    if (fetchState is CharacterSheetFetchSuccess) {
      return _buildFetchResultCard(fetchState.result, fetchState.serviceName);
    }

    // エラー時
    if (fetchState is CharacterSheetFetchError) {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fetchState.message,
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

    // ローディング時
    if (fetchState is CharacterSheetFetchLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text('${fetchState.serviceName}からデータを取得中...'),
            ],
          ),
        ),
      );
    }

    // 既存のステータス情報がある場合
    if (_hasStats) {
      return _buildCurrentStatsCard();
    }

    return const SizedBox.shrink();
  }

  Widget _buildFetchResultCard(CharacterSheetResult result, String serviceName) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '$serviceNameから取得',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),

            // 取得したデータ表示
            if (result.name != null) ...[
              _buildResultRow('名前', result.name!),
            ],
            if (result.hp != null || result.maxHp != null) ...[
              _buildResultRow(
                'HP',
                '${result.hp ?? '?'} / ${result.maxHp ?? '?'}',
              ),
            ],
            if (result.mp != null || result.maxMp != null) ...[
              _buildResultRow(
                'MP',
                '${result.mp ?? '?'} / ${result.maxMp ?? '?'}',
              ),
            ],
            if (result.san != null || result.maxSan != null) ...[
              _buildResultRow(
                'SAN',
                '${result.san ?? '?'} / ${result.maxSan ?? '?'}',
              ),
            ],

            const SizedBox(height: 16),

            // 適用ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    ref.read(characterSheetFetchProvider.notifier).reset();
                  },
                  child: const Text('キャンセル'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _applyFetchResult(result, serviceName),
                  icon: const Icon(Icons.check),
                  label: const Text('適用'),
                ),
              ],
            ),
          ],
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
    return Wrap(
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
    );
  }

  Widget _buildStatChip(String label, int? current, int? max, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withAlpha(50),
        child: Text(
          label[0],
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
      label: Text('${current ?? '?'} / ${max ?? '?'}'),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
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
      _maxSan != null;

  Future<void> _fetchCharacterSheet() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    await ref.read(characterSheetFetchProvider.notifier).fetch(url);
  }

  void _applyFetchResult(CharacterSheetResult result, String serviceName) {
    setState(() {
      // 名前が取得できていて、現在空の場合のみ適用
      if (result.name != null && _nameController.text.trim().isEmpty) {
        _nameController.text = result.name!;
      }

      // ステータス情報を適用
      _hp = result.hp;
      _maxHp = result.maxHp;
      _mp = result.mp;
      _maxMp = result.maxMp;
      _san = result.san;
      _maxSan = result.maxSan;
      _sourceService = serviceName;
    });

    // 取得状態をリセット
    ref.read(characterSheetFetchProvider.notifier).reset();

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
