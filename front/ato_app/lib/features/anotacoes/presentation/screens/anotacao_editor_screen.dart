import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/ato_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/anotacao_repository.dart';
import '../../data/models/anotacao_models.dart';
import '../../providers/anotacao_provider.dart';

class AnotacaoEditorScreen extends ConsumerStatefulWidget {
  const AnotacaoEditorScreen({super.key, this.anotacao});

  /// Null = create mode. Non-null = edit mode.
  final Anotacao? anotacao;

  @override
  ConsumerState<AnotacaoEditorScreen> createState() =>
      _AnotacaoEditorScreenState();
}

class _AnotacaoEditorScreenState
    extends ConsumerState<AnotacaoEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagInputController;

  String? _selectedSubject;
  late List<String> _tags;
  bool _isSaving = false;

  bool get _isEditing => widget.anotacao != null;

  @override
  void initState() {
    super.initState();
    final a = widget.anotacao;
    _titleController = TextEditingController(text: a?.title ?? '');
    _contentController = TextEditingController(text: a?.content ?? '');
    _tagInputController = TextEditingController();
    _selectedSubject = a?.subject;
    _tags = List<String>.from(a?.tags ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _addTag(String input) {
    // Split by comma to allow multiple tags at once
    final parts = input.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty);
    setState(() {
      for (final tag in parts) {
        if (!_tags.contains(tag)) _tags.add(tag);
      }
    });
    _tagInputController.clear();
  }

  void _removeTag(String tag) => setState(() => _tags.remove(tag));

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'O conteúdo da anotação não pode estar vazio.',
            style: AppTextStyles.bodyMedium,
          ),
          backgroundColor: AppColors.backgroundCard,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(anotacaoRepositoryProvider);

      if (_isEditing) {
        await repo.updateAnnotation(
          id: widget.anotacao!.id,
          content: content,
          title: title.isNotEmpty ? title : null,
          tags: _tags,
          subject: _selectedSubject,
        );
      } else {
        await repo.createAnnotation(
          title: title.isNotEmpty ? title : 'Sem título',
          content: content,
          tags: _tags.isNotEmpty ? _tags : null,
          subject: _selectedSubject,
        );
      }

      ref.invalidate(anotacoesProvider);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao salvar. Tente novamente.',
              style: AppTextStyles.bodyMedium,
            ),
            backgroundColor: AppColors.backgroundCard,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: SvgPicture.asset(AtoIcons.logoIcon, height: 28),
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text('Salvar', style: AppTextStyles.accentMedium),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              style: AppTextStyles.h2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Título da anotação',
                hintStyle: AppTextStyles.h2.copyWith(
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: AppSpacing.lg),
            // Subject
            _SubjectSelector(
              selected: _selectedSubject,
              onChanged: (v) => setState(() => _selectedSubject = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Tags
            _TagsInput(
              tags: _tags,
              controller: _tagInputController,
              onAdd: _addTag,
              onRemove: _removeTag,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Content
            TextField(
              controller: _contentController,
              maxLines: null,
              minLines: 10,
              style: AppTextStyles.bodyLarge,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Escreva sua anotação...',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textMuted,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 1.5),
                ),
                fillColor: AppColors.backgroundCard,
                filled: true,
                contentPadding: AppSpacing.cardPadding,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

// ── Subject selector ──────────────────────────────────────────────────────────

class _SubjectSelector extends StatelessWidget {
  const _SubjectSelector({
    required this.selected,
    required this.onChanged,
  });

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Matéria', style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: AppRadius.input,
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: selected,
              isExpanded: true,
              dropdownColor: AppColors.backgroundSheet,
              iconEnabledColor: AppColors.textSecondary,
              hint: Text(
                'Selecione uma matéria',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              ),
              style: AppTextStyles.bodyMedium,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'Nenhuma',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textMuted),
                  ),
                ),
                ...kAnnotationSubjects.map(
                  (s) => DropdownMenuItem<String?>(
                    value: s,
                    child: Text(s, style: AppTextStyles.bodyMedium),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
        if (selected != null) ...[
          const SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: () => onChanged(null),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.chip,
                color: AppColors.tagBackground,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selected!,
                    style:
                        AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.close,
                    size: 11,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Tags input ────────────────────────────────────────────────────────────────

class _TagsInput extends StatelessWidget {
  const _TagsInput({
    required this.tags,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> tags;
  final TextEditingController controller;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        if (tags.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: tags
                .map((tag) => _EditableTagChip(
                      label: tag,
                      onRemove: () => onRemove(tag),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextField(
          controller: controller,
          style: AppTextStyles.bodyMedium,
          onSubmitted: onAdd,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Adicionar tag (Enter ou vírgula para confirmar)',
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add, color: AppColors.textMuted, size: 20),
              onPressed: () => onAdd(controller.text),
            ),
            filled: true,
            fillColor: AppColors.backgroundCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide:
                  const BorderSide(color: AppColors.accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditableTagChip extends StatelessWidget {
  const _EditableTagChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.chip,
        border: Border.all(color: AppColors.borderAccent),
        color: AppColors.accent.withValues(alpha: 0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 12,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
