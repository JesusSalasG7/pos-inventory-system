import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/skeleton.dart';

/// Pinta un `AsyncValue` con sus cuatro estados: carga (esqueleto), vacío,
/// error con reintento y datos.
///
/// Mientras se refresca conserva los datos anteriores en pantalla, para que
/// el pull-to-refresh no haga parpadear la lista.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.data,
    this.onRetry,
    this.loading,
    this.isEmpty,
    this.empty,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  /// Estado de carga; por defecto una lista de esqueletos.
  final Widget? loading;

  /// Indica si los datos cargados deben mostrarse como estado vacío.
  final bool Function(T data)? isEmpty;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    if (value.hasValue) {
      final loaded = value.requireValue;
      if (isEmpty?.call(loaded) ?? false) return empty ?? const EmptyState();
      return data(loaded);
    }
    if (value.hasError) {
      final failure = Failure.from(value.error!);
      return EmptyState(
        icon: failure.isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
        title: Strings.errorTitle,
        message: failure.message,
        actionLabel: onRetry == null ? null : Strings.retry,
        onAction: onRetry,
        iconColor: AppColors.error,
        iconBackground: AppColors.errorSoft,
      );
    }
    return loading ?? const SkeletonList();
  }
}
