import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/core/storage/rate_notice_storage.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/exchange_rate.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rate_change_notice_provider.g.dart';

@Riverpod(keepAlive: true)
RateNoticeStorage rateNoticeStorage(Ref ref) => SecureRateNoticeStorage();

/// Aviso pendiente de que la tasa activa cambió desde la última vez que se vio.
@immutable
class RateChangeNotice {
  const RateChangeNotice({required this.current, this.previousRate});

  final ExchangeRate current;

  /// Valor de la tasa que estaba activa la última vez, si se conoce.
  final Decimal? previousRate;
}

/// Detecta los cambios de tasa comparando la activa con la última vista en el
/// dispositivo. La primera tasa que se ve no avisa: solo se recuerda.
@Riverpod(keepAlive: true)
class RateChangeNoticeController extends _$RateChangeNoticeController {
  @override
  RateChangeNotice? build() {
    ref.listen(activeExchangeRateProvider, (_, next) {
      final rate = next.value;
      if (rate != null) _check(rate);
    }, fireImmediately: true);
    return null;
  }

  Future<void> _check(ExchangeRate rate) async {
    final storage = ref.read(rateNoticeStorageProvider);
    final seen = await storage.read();
    if (seen == null) {
      await storage.save(id: rate.id, rate: rate.rate.toString());
      return;
    }
    if (seen.id == rate.id || state?.current.id == rate.id) return;
    state = RateChangeNotice(current: rate, previousRate: Decimal.tryParse(seen.rate));
  }

  /// El usuario vio el aviso: la tasa actual pasa a ser la última vista.
  Future<void> acknowledge() async {
    final notice = state;
    if (notice == null) return;
    state = null;
    await ref
        .read(rateNoticeStorageProvider)
        .save(id: notice.current.id, rate: notice.current.rate.toString());
  }
}
