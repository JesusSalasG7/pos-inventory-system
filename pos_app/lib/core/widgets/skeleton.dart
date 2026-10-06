import 'package:flutter/material.dart';

import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';

/// Bloque gris que late suavemente mientras se cargan los datos.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({this.width, this.height = 16, this.borderRadius = AppRadius.smAll, super.key});

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: widget.borderRadius),
      ),
    );
  }
}

/// Lista de filas esqueleto: el estado de carga por defecto de las listas.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    this.itemCount = 5,
    this.itemHeight = 72,
    this.shrinkWrap = false,
    super.key,
  });

  final int itemCount;
  final double itemHeight;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => SkeletonBox(height: itemHeight, borderRadius: AppRadius.mdAll),
    );
  }
}
