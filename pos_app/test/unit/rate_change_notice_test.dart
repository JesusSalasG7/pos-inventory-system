import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/storage/rate_notice_storage.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/exchange_rate.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/rate_change_notice_provider.dart';

import '../mocks/fake_repositories.dart';

ExchangeRate bcvRate(int id, String rate, int day) => ExchangeRate(
  id: id,
  rate: dec(rate),
  source: RateSource.bcv,
  effectiveDate: DateTime(2026, 10, day),
  createdAt: DateTime.utc(2026, 10, day, 12),
);

void main() {
  late FakeExchangeRateRepository rates;
  late InMemoryRateNoticeStorage storage;

  Future<ProviderContainer> readyContainer() async {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: supervisor(), hasSession: true),
        branches: FakeBranchRepository([villaLibertad]),
        rates: rates,
        rateNotice: storage,
      ),
    );
    addTearDown(container.dispose);
    container.listen(rateChangeNoticeControllerProvider, (_, _) {});
    await settledSession(container);
    await container.read(activeExchangeRateProvider.future);
    await Future<void>.delayed(Duration.zero);
    return container;
  }

  setUp(() {
    rates = FakeExchangeRateRepository()..active = bcvRate(7, '872.3927', 6);
    storage = InMemoryRateNoticeStorage();
  });

  test('la primera tasa que se ve no avisa: solo se recuerda', () async {
    final container = await readyContainer();

    expect(container.read(rateChangeNoticeControllerProvider), isNull);
    expect(storage.value, (id: 7, rate: '872.3927'));
  });

  test('si la tasa es la misma que la última vista, no avisa', () async {
    storage.value = (id: 7, rate: '872.3927');
    final container = await readyContainer();

    expect(container.read(rateChangeNoticeControllerProvider), isNull);
  });

  test('si cambió mientras la app estaba cerrada, avisa con la tasa nueva y su día', () async {
    storage.value = (id: 6, rate: '860.5');
    final container = await readyContainer();

    final notice = container.read(rateChangeNoticeControllerProvider)!;
    expect(notice.current.rate, dec('872.3927'));
    expect(notice.current.source, RateSource.bcv);
    expect(notice.current.day, DateTime(2026, 10, 6));
    expect(notice.previousRate, dec('860.5'));
    // Hasta que el usuario no lo vea, la última vista sigue siendo la anterior.
    expect(storage.value!.id, 6);
  });

  test('al confirmar el aviso, la tasa nueva pasa a ser la última vista', () async {
    storage.value = (id: 6, rate: '860.5');
    final container = await readyContainer();

    await container.read(rateChangeNoticeControllerProvider.notifier).acknowledge();

    expect(container.read(rateChangeNoticeControllerProvider), isNull);
    expect(storage.value, (id: 7, rate: '872.3927'));
  });

  test('avisa cuando la tasa cambia con la app abierta', () async {
    final container = await readyContainer();
    expect(container.read(rateChangeNoticeControllerProvider), isNull);

    // El servidor sincronizó con el BCV; la app lo ve en su siguiente consulta.
    rates.active = bcvRate(8, '875.1', 7);
    await container.read(activeExchangeRateProvider.notifier).refresh();
    await Future<void>.delayed(Duration.zero);

    final notice = container.read(rateChangeNoticeControllerProvider)!;
    expect(notice.current.id, 8);
    expect(notice.current.day, DateTime(2026, 10, 7));
    expect(notice.previousRate, dec('872.3927'));
  });

  test('sincronizar desde la app actualiza la tasa activa y avisa', () async {
    final container = await readyContainer();
    rates.nextBcvRate = bcvRate(9, '880', 8);

    final changed = await container.read(activeExchangeRateProvider.notifier).syncWithBcv();
    await Future<void>.delayed(Duration.zero);

    expect(changed, isTrue);
    expect(await container.read(activeRateProvider.future), dec('880'));
    expect(container.read(rateChangeNoticeControllerProvider)!.current.id, 9);

    // Sin publicación nueva del BCV no cambia nada.
    expect(await container.read(activeExchangeRateProvider.notifier).syncWithBcv(), isFalse);
  });

  test('una tasa manual corresponde al día en que se registró (hora de Caracas)', () {
    final manual = ExchangeRate(
      id: 1,
      rate: dec('900'),
      // 02:30 UTC del día 7 son las 22:30 del día 6 en Caracas.
      createdAt: DateTime.utc(2026, 10, 7, 2, 30),
    );

    expect(manual.source, RateSource.manual);
    expect(manual.day, DateTime(2026, 10, 6));
  });
}
