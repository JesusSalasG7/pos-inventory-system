import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_expired_provider.g.dart';

/// Señal de que el refresh token venció y hay que volver al login.
///
/// Es un contador: cada vencimiento lo incrementa y quien escucha reacciona.
@Riverpod(keepAlive: true)
class SessionExpired extends _$SessionExpired {
  @override
  int build() => 0;

  void notify() => state++;
}
