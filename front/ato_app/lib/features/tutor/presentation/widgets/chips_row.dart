import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class ChipsRow extends StatefulWidget {
  const ChipsRow({super.key, required this.chips, required this.onTap});

  final List<String> chips;
  final ValueChanged<String> onTap;

  @override
  State<ChipsRow> createState() => _ChipsRowState();
}

class _ChipsRowState extends State<ChipsRow> {
  late final ScrollController _scrollController;
  bool _fadeLeft = false;
  bool _fadeRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateFade);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFade());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateFade);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFade() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final hasOverflow = pos.maxScrollExtent > 0;
    final nextLeft = hasOverflow && pos.pixels > 1;
    final nextRight = hasOverflow && pos.pixels < pos.maxScrollExtent - 1;
    if (_fadeLeft != nextLeft || _fadeRight != nextRight) {
      setState(() {
        _fadeLeft = nextLeft;
        _fadeRight = nextRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chips.isEmpty) return const SizedBox.shrink();

    final list = ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.chips.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final chip = widget.chips[index];
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Material(
              color: Colors.transparent,
              borderRadius: AppRadius.chip,
              child: InkWell(
                onTap: () => widget.onTap(chip),
                borderRadius: AppRadius.chip,
                splashColor: AppColors.accent.withValues(alpha: 0.12),
                highlightColor: AppColors.accent.withValues(alpha: 0.06),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: AppRadius.chip,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    chip,
                    style: AppTextStyles.labelMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg + 32 + AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: SizedBox(
        height: 36,
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0, 0.08, 0.92, 1.0],
              colors: [
                _fadeLeft ? Colors.transparent : Colors.white,
                Colors.white,
                Colors.white,
                _fadeRight ? Colors.transparent : Colors.white,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: list,
        ),
      ),
    );
  }
}
