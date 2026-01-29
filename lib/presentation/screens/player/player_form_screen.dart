import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/image_storage_service.dart';
import '../../providers/player_provider.dart';
import '../../widgets/image_selector.dart';

/// プレイヤー追加/編集画面
class PlayerFormScreen extends ConsumerStatefulWidget {
  const PlayerFormScreen({super.key, this.playerId});

  final int? playerId;

  @override
  ConsumerState<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends ConsumerState<PlayerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isInitialized = false;
  bool _isSaving = false;
  String? _currentImagePath;
  String? _originalImagePath;
  File? _selectedImageFile;

  bool get _isEdit => widget.playerId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _initializeFromPlayer() {
    if (_isInitialized || !_isEdit) return;
    final playerAsync = ref.read(playerDetailProvider(widget.playerId!));
    playerAsync.whenData((player) {
      if (_isInitialized) return;
      _nameController.text = player.name;
      _noteController.text = player.note ?? '';
      _currentImagePath = player.imagePath;
      _originalImagePath = player.imagePath;
      _isInitialized = true;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isEdit) {
      ref.watch(playerDetailProvider(widget.playerId!));
      _initializeFromPlayer();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'プレイヤーを編集' : 'プレイヤーを追加'),
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
                  setState(() {
                    _selectedImageFile = file;
                    _currentImagePath = file.path;
                  });
                },
                onImageRemoved: () {
                  setState(() {
                    _selectedImageFile = null;
                    _currentImagePath = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 名前
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名前 *',
                  hintText: 'プレイヤーの名前を入力',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '名前を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // メモ
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'メモ',
                  hintText: 'プレイヤーに関するメモ',
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

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final note = _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim();

      // 画像を保存
      String? imagePath = _currentImagePath;
      if (_selectedImageFile != null) {
        imagePath = await ImageStorageService().saveImage(_selectedImageFile!);
      } else if (_currentImagePath == null && _originalImagePath != null) {
        // 画像が削除された場合
        imagePath = null;
      }

      if (_isEdit) {
        await ref.read(playerListProvider.notifier).updatePlayer(
              id: widget.playerId!,
              name: name,
              note: note,
              imagePath: imagePath,
              oldImagePath: _originalImagePath,
            );
        ref.invalidate(playerDetailProvider(widget.playerId!));
        ref.invalidate(playerSessionCountProvider(widget.playerId!));
        ref.invalidate(playerPlayedScenariosProvider(widget.playerId!));
      } else {
        await ref.read(playerListProvider.notifier).add(
              name: name,
              note: note,
              imagePath: imagePath,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(_isEdit ? 'プレイヤーを更新しました' : 'プレイヤーを追加しました'),
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
