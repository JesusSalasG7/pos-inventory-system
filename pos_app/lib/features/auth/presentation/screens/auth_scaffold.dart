import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';

/// Marca de la app: el ícono dentro de un círculo blanco.
class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 72, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
      child: Icon(Icons.storefront_rounded, size: size * 0.52, color: AppColors.primaryDark),
    );
  }
}

/// Estructura común de las pantallas de entrada (login, sucursal): una
/// cabecera en el color de marca y el contenido en una hoja blanca redondeada.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.leading,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  /// Acción arriba a la izquierda, p. ej. volver.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.sm)],
                        const BrandMark(size: 52),
                        const SizedBox(width: AppSpacing.md),
                        Flexible(
                          child: Text(
                            Strings.appName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.subtitle.copyWith(color: AppColors.onPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(title, style: AppTypography.headline.copyWith(color: AppColors.onPrimary)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle, style: AppTypography.body.copyWith(color: AppColors.onPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aviso de error dentro de un formulario.
class FormErrorBanner extends StatelessWidget {
  const FormErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(color: AppColors.errorSoft, borderRadius: AppRadius.mdAll),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(message, style: AppTypography.body.copyWith(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}
