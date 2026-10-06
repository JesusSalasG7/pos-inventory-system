import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_reachability_provider.g.dart';

/// Indica si la última petición no pudo llegar al servidor.
///
/// Lo actualiza `ErrorInterceptor`; `OfflineBanner` lo muestra.
@Riverpod(keepAlive: true)
class ServerOffline extends _$ServerOffline {
  @override
  bool build() => false;

  void set({required bool offline}) {
    if (state != offline) state = offline;
  }
}
