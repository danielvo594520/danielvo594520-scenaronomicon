import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/character_provider.dart';
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

              // URL
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'キャラクターシートURL',
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.link),
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
            );
        ref.invalidate(characterDetailProvider(widget.characterId!));
      } else {
        await ref
            .read(characterListProvider(widget.playerId).notifier)
            .add(
              name: name,
              url: url,
              imageFile: _newImageFile,
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
