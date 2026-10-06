import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/network/paged_list.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/cash_session/domain/cash_count.dart';

import '../mocks/fake_repositories.dart';

void main() {
  group('diferencia del arqueo (misma fórmula que el backend)', () {
    test('cuadra cuando lo contado es igual a lo esperado', () {
      final difference = CashCount.differenceUsd(
        countedUsd: dec('120.00'),
        countedVes: dec('3000.00'),
        expectedUsd: dec('120.00'),
        expectedVes: dec('3000.00'),
        usdToVesRate: dec('150'),
      );
      expect(difference, dec('0.00'));
    });

    test('sobrante en dólares es positivo', () {
      final difference = CashCount.differenceUsd(
        countedUsd: dec('125.50'),
        countedVes: dec('3000'),
        expectedUsd: dec('120'),
        expectedVes: dec('3000'),
        usdToVesRate: dec('150'),
      );
      expect(difference, dec('5.50'));
    });

    test('faltante en bolívares se convierte a dólares con la tasa', () {
      final difference = CashCount.differenceUsd(
        countedUsd: dec('120'),
        countedVes: dec('2700'),
        expectedUsd: dec('120'),
        expectedVes: dec('3000'),
        usdToVesRate: dec('150'),
      );
      expect(difference, dec('-2.00'));
    });

    test('un sobrante en una moneda compensa el faltante en la otra', () {
      final difference = CashCount.differenceUsd(
        countedUsd: dec('118'),
        countedVes: dec('3300'),
        expectedUsd: dec('120'),
        expectedVes: dec('3000'),
        usdToVesRate: dec('150'),
      );
      expect(difference, dec('0.00'));
    });

    test('redondea a 2 decimales', () {
      final difference = CashCount.differenceUsd(
        countedUsd: dec('0'),
        countedVes: dec('100'),
        expectedUsd: dec('0'),
        expectedVes: dec('0'),
        usdToVesRate: dec('872.3927'),
      );
      expect(difference, dec('0.11'));
    });
  });

  group('PagedList', () {
    test('acumula páginas y sabe cuándo no hay más', () {
      final first = PagedList.first(
        const Paginated(count: 5, results: [1, 2], next: 'http://x/?page=2'),
      );
      expect(first.hasMore, isTrue);
      expect(first.nextPage, 2);

      final second = first.append(
        const Paginated(count: 5, results: [3, 4], next: 'http://x/?page=3'),
      );
      expect(second.items, [1, 2, 3, 4]);
      expect(second.nextPage, 3);

      final last = second.append(const Paginated(count: 5, results: [5]));
      expect(last.items, [1, 2, 3, 4, 5]);
      expect(last.hasMore, isFalse);
      expect(last.totalCount, 5);
    });
  });
}
