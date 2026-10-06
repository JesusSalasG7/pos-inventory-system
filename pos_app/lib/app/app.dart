import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos_app/app/router/app_router.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';

class PosApp extends ConsumerStatefulWidget {
  const PosApp({super.key});

  @override
  ConsumerState<PosApp> createState() => _PosAppState();
}

class _PosAppState extends ConsumerState<PosApp> with WidgetsBindingObserver {
  /// Cada cuánto se vuelve a consultar la tasa mientras la app está abierta.
  /// El servidor la cambia solo cuando el BCV publica una nueva.
  static const Duration _rateRefreshInterval = Duration(minutes: 10);

  Timer? _rateTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _rateTimer = Timer.periodic(
      _rateRefreshInterval,
      (_) => ref.invalidate(activeExchangeRateProvider),
    );
  }

  @override
  void dispose() {
    _rateTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // La tasa puede haber cambiado mientras la app estaba en segundo plano.
    if (state == AppLifecycleState.resumed) ref.invalidate(activeExchangeRateProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: Strings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
      locale: const Locale('es', 'VE'),
      supportedLocales: const [Locale('es', 'VE'), Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          // Se respeta el tamaño de letra del sistema, pero acotado: los montos
          // y las tarjetas del POS no deben desbordarse en el mostrador.
          data: media.copyWith(
            textScaler: media.textScaler.clamp(minScaleFactor: 1, maxScaleFactor: 1.15),
          ),
          child: _OrientationLock(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}

/// Bloquea la orientación vertical en teléfonos; las tablets pueden girar.
class _OrientationLock extends StatefulWidget {
  const _OrientationLock({required this.child});

  final Widget child;

  @override
  State<_OrientationLock> createState() => _OrientationLockState();
}

class _OrientationLockState extends State<_OrientationLock> {
  bool? _isPhone;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isPhone = MediaQuery.sizeOf(context).shortestSide < AppSpacing.tabletBreakpoint;
    if (isPhone == _isPhone) return;
    _isPhone = isPhone;
    SystemChrome.setPreferredOrientations(
      isPhone ? const [DeviceOrientation.portraitUp] : DeviceOrientation.values,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
