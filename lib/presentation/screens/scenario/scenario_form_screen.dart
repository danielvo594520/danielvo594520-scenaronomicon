import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/image_storage_service.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../domain/enums/scenario_status.dart';
import '../../providers/scenario_provider.dart';
import '../../providers/system_provider.dart';
import '../../providers/tag_provider.dart';
import '../../widgets/image_selector.dart';

class ScenarioFormScreen extends ConsumerStatefulWidget {
  const ScenarioFormScreen({super.key, this.scenarioId});

  final int? scenarioId;

  @override
  ConsumerState<ScenarioFormScreen> createState() => _ScenarioFormScreenState();
}

class _ScenarioFormScreenState extends ConsumerState<ScenarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _minPlayersController = TextEditingController(text: '1');
  final _maxPlayersController = TextEditingController(text: '4');
  final _playTimeController = TextEditingController();
  final _purchaseUrlController = TextEditingController();
  final _memoController = TextEditingController();

  int? _selectedSystemId;
  ScenarioStatus _selectedStatus = ScenarioStatus.unread;
  Set<int> _selectedTagIds = {};
  bool _isInitialized = false;
  bool _isSaving = false;

  // 画像関連
  String? _currentImagePath; // 保存済みパス or 一時パス
  File? _selectedImageFile; // 新しく選択された画像ファイル
  String? _originalImagePath; // 編集時の元画像パス（削除判定用）
  bool _imageRemoved = false; // 画像を明示的に削除したか

  bool get _isEdit => widget.scenarioId != null;

  @override
  void dispose() {
    _titleController.dispose();
    _minPlayersController.dispose();
    _maxPlayersController.dispose();
    _playTimeController.dispose();
    _purchaseUrlController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _initializeFromScenario() {
    if (_isInitialized || !_isEdit) return;
    final scenarioAsync = ref.read(scenarioDetailProvider(widget.scenarioId!));
    scenarioAsync.whenData((scenario) {
      if (_isInitialized) return;
      _titleController.text = scenario.title;
      _selectedSystemId = scenario.systemId;
      _minPlayersController.text = scenario.minPlayers.toString();
      _maxPlayersController.text = scenario.maxPlayers.toString();
      if (scenario.playTimeMinutes != null) {
        _playTimeController.text = scenario.playTimeMinutes.toString();
      }
      _selectedStatus = scenario.status;
      _purchaseUrlController.text = scenario.purchaseUrl ?? '';
      _memoController.text = scenario.memo ?? '';
      _selectedTagIds = scenario.tags.map((t) => t.id).toSet();
      _currentImagePath = scenario.thumbnailPath;
      _originalImagePath = scenario.thumbnailPath;
      _isInitialized = true;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final systemsAsync = ref.watch(systemListProvider);
    final tagsAsync = ref.watch(tagListProvider);

    if (_isEdit) {
      ref.watch(scenarioDetailProvider(widget.scenarioId!));
      _initializeFromScenario();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'シナリオを編集' : 'シナリオを追加'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // サムネイル画像
              ImageSelector(
                currentImagePath: _currentImagePath,
                onImageSelected: (file) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedImageFile = file;
                    _currentImagePath = file.path;
                    _imageRemoved = false;
                  });
                },
                onImageRemoved: () {
                  setState(() {
                    _selectedImageFile = null;
                    _currentImagePath = null;
                    _imageRemoved = true;
                  });
                },
              ),
              const SizedBox(height: 16),

              // タイトル
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル *',
                  hintText: 'シナリオのタイトルを入力',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'タイトルを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // システム
              systemsAsync.when(
                loading: () =>
                    const LinearProgressIndicator(),
                error: (_, __) => const Text('システムの読み込みに失敗しました'),
                data: (systems) => DropdownButtonFormField<int?>(
                  value: _selectedSystemId,
                  decoration: const InputDecoration(labelText: 'ゲームシステム'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('未設定'),
                    ),
                    ...systems.map((s) => DropdownMenuItem<int?>(
                          value: s.id,
                          child: Text(s.name),
                        )),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedSystemId = value),
                ),
              ),
              const SizedBox(height: 16),

              // 人数
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minPlayersController,
                      decoration: const InputDecoration(labelText: '最小人数 *'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '必須';
                        }
                        final n = int.tryParse(value);
                        if (n == null || n < 1) return '1以上';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxPlayersController,
                      decoration: const InputDecoration(labelText: '最大人数 *'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '必須';
                        }
                        final n = int.tryParse(value);
                        if (n == null || n < 1) return '1以上';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // プレイ時間
              TextFormField(
                controller: _playTimeController,
                decoration: const InputDecoration(
                  labelText: 'プレイ時間（分）',
                  hintText: '例: 120',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final n = int.tryParse(value);
                    if (n == null || n < 0) return '0以上の数値を入力';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ステータス
              DropdownButtonFormField<ScenarioStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'ステータス *'),
                items: ScenarioStatus.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // タグ
              tagsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('タグの読み込みに失敗しました'),
                data: (tags) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('タグ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            )),
                    const SizedBox(height: 8),
                    if (tags.isEmpty)
                      Text('タグがありません',
                          style: TextStyle(color: Colors.grey[400]))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: tags.map((tag) {
                          final isSelected = _selectedTagIds.contains(tag.id);
                          return FilterChip(
                            label: Text(tag.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTagIds.add(tag.id);
                                } else {
                                  _selectedTagIds.remove(tag.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 購入URL
              TextFormField(
                controller: _purchaseUrlController,
                decoration: const InputDecoration(
                  labelText: '購入URL',
                  hintText: 'https://...',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasScheme) {
                      return '有効なURLを入力してください';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // メモ
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: 'メモ',
                  hintText: 'シナリオに関するメモ',
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // クロスフィールドバリデーション
    final minPlayers = int.parse(_minPlayersController.text);
    final maxPlayers = int.parse(_maxPlayersController.text);
    if (maxPlayers < minPlayers) {
      showErrorSnackBar(context, '最大人数は最小人数以上にしてください');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final title = _titleController.text.trim();
      final playTime = _playTimeController.text.isEmpty
          ? null
          : int.parse(_playTimeController.text);
      final purchaseUrl = _purchaseUrlController.text.trim().isEmpty
          ? null
          : _purchaseUrlController.text.trim();
      final memo = _memoController.text.trim().isEmpty
          ? null
          : _memoController.text.trim();

      // 画像の保存処理
      String? thumbnailPath;
      if (_selectedImageFile != null) {
        // 新しい画像が選択された場合、アプリ専用ディレクトリに保存
        final storageService = ImageStorageService();
        thumbnailPath = await storageService.saveImage(_selectedImageFile!);
      } else if (!_imageRemoved) {
        // 画像が削除されておらず、新しい画像も選択されていない場合は元のパスを維持
        thumbnailPath = _originalImagePath;
      }
      // _imageRemoved == true && _selectedImageFile == null の場合は thumbnailPath = null

      if (_isEdit) {
        await ref.read(scenarioListProvider.notifier).updateScenario(
              id: widget.scenarioId!,
              title: title,
              systemId: _selectedSystemId,
              minPlayers: minPlayers,
              maxPlayers: maxPlayers,
              playTimeMinutes: playTime,
              status: _selectedStatus,
              purchaseUrl: purchaseUrl,
              thumbnailPath: thumbnailPath,
              oldThumbnailPath: _originalImagePath,
              memo: memo,
              tagIds: _selectedTagIds.toList(),
            );
        // 詳細画面のキャッシュもリフレッシュ
        ref.invalidate(scenarioDetailProvider(widget.scenarioId!));
      } else {
        await ref.read(scenarioListProvider.notifier).add(
              title: title,
              systemId: _selectedSystemId,
              minPlayers: minPlayers,
              maxPlayers: maxPlayers,
              playTimeMinutes: playTime,
              status: _selectedStatus,
              purchaseUrl: purchaseUrl,
              thumbnailPath: thumbnailPath,
              memo: memo,
              tagIds: _selectedTagIds.toList(),
            );
      }

      if (mounted) {
        showSuccessSnackBar(
            context, _isEdit ? 'シナリオを更新しました' : 'シナリオを追加しました');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'エラー: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
